import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';

import '../constant.dart';
import '../controllers/letter_sounds_controller.dart';
import '../models/letter_sound_models.dart';
import '../widgets/page_header.dart';

class LetterSoundsScreen extends StatefulWidget {
  const LetterSoundsScreen({Key? key}) : super(key: key);

  @override
  State<LetterSoundsScreen> createState() => _LetterSoundsScreenState();
}

class _LetterSoundsScreenState extends State<LetterSoundsScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final PageController _pageController = PageController(viewportFraction: 0.86);
  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Random _random = Random();
  late final AnimationController _heroController;

  int _selectedStageIndex = 0;
  int _selectedItemIndex = 0;
  int _stars = 0;
  int _letterQuizSeed = 0;
  int _pictureQuizSeed = 0;
  int _successPulse = 0;
  double _offset = 0;
  LetterSoundItem? _letterQuizTarget;
  List<LetterSoundItem> _letterQuizOptions = const [];
  LetterSoundItem? _pictureQuizTarget;
  List<LetterSoundItem> _pictureQuizOptions = const [];

  LetterSoundStage get _stage => letterSoundStages[_selectedStageIndex];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _heroController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _prepareQuizRound();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pageController.dispose();
    _heroController.dispose();
    _audioPlayer.dispose();
    _tts.stop();
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _offset = _scrollController.hasClients ? _scrollController.offset : 0;
    });
  }

  Future<void> _speakEnglish(String text, {double rate = 0.4}) async {
    await _tts.stop();
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(rate);
    await _tts.setPitch(1.0);
    await _tts.speak(text);
  }

  Future<void> _speakChinese(String text, {double rate = 0.46}) async {
    await _tts.stop();
    await _tts.setLanguage('zh-CN');
    await _tts.setSpeechRate(rate);
    await _tts.setPitch(1.0);
    await _tts.speak(text);
  }

  Future<void> _playAssetOrFallback(
    String assetPath,
    Future<void> Function() fallback,
  ) async {
    HapticFeedback.selectionClick();
    try {
      await _audioPlayer.stop();
      await _audioPlayer.setAsset(assetPath);
      await _audioPlayer.play();
    } catch (_) {
      await fallback();
    }
  }

  List<LetterSoundItem> _shuffledOptions(List<LetterSoundItem> source) {
    final items = List<LetterSoundItem>.from(source);
    items.shuffle(_random);
    return items;
  }

  void _prepareQuizRound() {
    final items = _stage.items;
    _letterQuizTarget = items[_random.nextInt(items.length)];
    _pictureQuizTarget = items[_random.nextInt(items.length)];
    _letterQuizOptions = _shuffledOptions(items);
    _pictureQuizOptions = _shuffledOptions(items);
  }

  Future<void> _selectStage(int index) async {
    if (_selectedStageIndex == index) {
      await _playAssetOrFallback(
        _stage.introAudioAsset,
        () => _speakChinese(_stage.chinesePrompt),
      );
      return;
    }

    setState(() {
      _selectedStageIndex = index;
      _selectedItemIndex = 0;
      _prepareQuizRound();
    });

    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }

    await _playAssetOrFallback(
      _stage.introAudioAsset,
      () => _speakChinese(_stage.chinesePrompt),
    );
  }

  Future<void> _celebrate() async {
    setState(() {
      _stars += 1;
      _successPulse += 1;
    });
    HapticFeedback.mediumImpact();
  }

  Future<void> _answerLetterQuiz(LetterSoundItem answer) async {
    if (_letterQuizTarget == null) {
      return;
    }

    if (answer.letter == _letterQuizTarget!.letter) {
      await _celebrate();
      await _playAssetOrFallback(
        answer.chantAudioAsset,
        () => _speakEnglish(answer.chant, rate: 0.36),
      );
      if (mounted) {
        setState(() {
          _letterQuizSeed += 1;
          _letterQuizTarget =
              _stage.items[_random.nextInt(_stage.items.length)];
          _letterQuizOptions = _shuffledOptions(_stage.items);
        });
      }
    } else {
      await _playAssetOrFallback(
        answer.promptAudioAsset,
        () => _speakChinese('再听一遍，慢慢找，不着急。'),
      );
    }
  }

  Future<void> _answerPictureQuiz(LetterSoundItem answer) async {
    if (_pictureQuizTarget == null) {
      return;
    }

    if (answer.letter == _pictureQuizTarget!.letter) {
      await _celebrate();
      await _playAssetOrFallback(
        answer.primaryWordAudioAsset,
        () => _speakEnglish(answer.primaryWord),
      );
      if (mounted) {
        setState(() {
          _pictureQuizSeed += 1;
          _pictureQuizTarget =
              _stage.items[_random.nextInt(_stage.items.length)];
          _pictureQuizOptions = _shuffledOptions(_stage.items);
        });
      }
    } else {
      await _playAssetOrFallback(
        answer.promptAudioAsset,
        () => _speakChinese('我们再听一遍小单词。'),
      );
    }
  }

  Widget _buildHeroCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 18),
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF6CF), Color(0xFFFFD7E8), Color(0xFFD9F3FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: kActiveShadowColor,
            offset: const Offset(0, 10),
            blurRadius: 24,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Letter Sounds',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: kTitleTextColor,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '听声音、看图片、点一点、说一说。把练习册里的自然拼读，变成小朋友一看就会玩的发音乐园。',
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: kBodyTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 110,
                height: 110,
                child: AnimatedBuilder(
                  animation: _heroController,
                  builder: (context, child) {
                    final value = _heroController.value;
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          left: 6 + 10 * value,
                          top: 12,
                          child: const _HeroBubble(
                            label: 'A',
                            color: Color(0xFFFFB74D),
                            size: 44,
                          ),
                        ),
                        Positioned(
                          right: 2,
                          top: 18 + 10 * (1 - value),
                          child: const _HeroBubble(
                            label: 'B',
                            color: Color(0xFF64B5F6),
                            size: 38,
                          ),
                        ),
                        Positioned(
                          left: 26,
                          bottom: 2 + 10 * value,
                          child: const _HeroBubble(
                            label: 'C',
                            color: Color(0xFF81C784),
                            size: 50,
                          ),
                        ),
                        Positioned(
                          right: 18,
                          bottom: 18,
                          child: Transform.rotate(
                            angle: pi / 10 * (value - 0.5),
                            child:
                                const Text('✨', style: TextStyle(fontSize: 24)),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _HeroAction(
                icon: Icons.play_circle_fill_rounded,
                label: '播放引导',
                onTap: () => _playAssetOrFallback(
                  'assets/audio/tts/letter_sounds/intro/welcome.mp3',
                  () => _speakChinese(
                    '欢迎来到字母发音乐园。先听声音，再看图片，最后勇敢说出来。',
                  ),
                ),
              ),
              _HeroAction(
                icon: Icons.auto_awesome,
                label: '这一关怎么学',
                onTap: () => _playAssetOrFallback(
                  _stage.introAudioAsset,
                  () => _speakChinese(_stage.chinesePrompt),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStageSelector() {
    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        physics: const BouncingScrollPhysics(),
        itemCount: letterSoundStages.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final stage = letterSoundStages[index];
          final selected = index == _selectedStageIndex;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              gradient: selected
                  ? LinearGradient(
                      colors: [stage.primaryColor, stage.secondaryColor],
                    )
                  : null,
              color: selected ? null : Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: selected
                      ? stage.secondaryColor.withValues(alpha: 0.18)
                      : Colors.black.withValues(alpha: 0.05),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: () => _selectStage(index),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Center(
                    child: Text(
                      stage.code,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: selected ? Colors.white : kTitleTextColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStageCard() {
    final stage = _stage;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      child: Container(
        key: ValueKey(stage.code),
        margin: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: LinearGradient(
            colors: [
              stage.primaryColor.withValues(alpha: 0.84),
              stage.secondaryColor.withValues(alpha: 0.94),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: stage.secondaryColor.withValues(alpha: 0.2),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stage.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    stage.subtitle,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.45,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            TweenAnimationBuilder<double>(
              key: ValueKey(_successPulse),
              tween: Tween(begin: 0.9, end: 1.0),
              duration: const Duration(milliseconds: 320),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(scale: value, child: child);
              },
              child: Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.35)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('⭐', style: TextStyle(fontSize: 22)),
                    const SizedBox(height: 2),
                    Text(
                      '$_stars',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLetterCarousel() {
    final items = _stage.items;
    return SizedBox(
      height: 356,
      child: PageView.builder(
        controller: _pageController,
        itemCount: items.length,
        physics: const BouncingScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _selectedItemIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final item = items[index];
          final selected = index == _selectedItemIndex;
          return AnimatedScale(
            duration: const Duration(milliseconds: 220),
            scale: selected ? 1 : 0.96,
            child: _LetterCard(
              item: item,
              selected: selected,
              onPlaySound: () => _playAssetOrFallback(
                item.soundAudioAsset,
                () => _speakEnglish(item.soundCue),
              ),
              onPlayPrimary: () => _playAssetOrFallback(
                item.primaryWordAudioAsset,
                () => _speakEnglish(item.primaryWord),
              ),
              onPlaySecondary: () => _playAssetOrFallback(
                item.secondaryWordAudioAsset,
                () => _speakEnglish(item.secondaryWord),
              ),
              onPlayPrompt: () => _playAssetOrFallback(
                item.promptAudioAsset,
                () => _speakChinese(item.chinesePrompt),
              ),
              onPlayChant: () => _playAssetOrFallback(
                item.chantAudioAsset,
                () => _speakEnglish(item.chant, rate: 0.36),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDots() {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 22),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_stage.items.length, (index) {
          final active = index == _selectedItemIndex;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: active ? 24 : 9,
            height: 9,
            decoration: BoxDecoration(
              color: active ? _stage.secondaryColor : Colors.grey[300],
              borderRadius: BorderRadius.circular(99),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLetterQuiz() {
    final target = _letterQuizTarget;
    if (target == null) {
      return const SizedBox.shrink();
    }

    return _GameCard(
      key: ValueKey('letter-$_letterQuizSeed-${target.letter}'),
      title: '听一听，找字母',
      subtitle: '先按播放，再点对开头声音一样的字母泡泡。',
      colorA: const Color(0xFFFFF3E0),
      colorB: const Color(0xFFFFE0F2),
      actionIcon: Icons.volume_up_rounded,
      onAction: () => _playAssetOrFallback(
        target.soundAudioAsset,
        () => _speakEnglish(target.soundCue),
      ),
      child: Wrap(
        spacing: 14,
        runSpacing: 14,
        children: _letterQuizOptions
            .map(
              (item) => _QuizBubble(
                label: item.letter,
                emoji: item.primaryEmoji,
                color: item.accentColor,
                onTap: () => _answerLetterQuiz(item),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildPictureQuiz() {
    final target = _pictureQuizTarget;
    if (target == null) {
      return const SizedBox.shrink();
    }

    return _GameCard(
      key: ValueKey('picture-$_pictureQuizSeed-${target.letter}'),
      title: '听一听，找图片',
      subtitle: '这个小游戏更适合小朋友，听到单词后，点它对应的图片。',
      colorA: const Color(0xFFE8F5E9),
      colorB: const Color(0xFFE1F5FE),
      actionIcon: Icons.hearing_rounded,
      onAction: () => _playAssetOrFallback(
        target.primaryWordAudioAsset,
        () => _speakEnglish(target.primaryWord),
      ),
      child: Wrap(
        spacing: 14,
        runSpacing: 14,
        children: _pictureQuizOptions
            .map(
              (item) => _PictureChoice(
                emoji: item.primaryEmoji,
                label: item.primaryWord,
                color: item.accentColor,
                onTap: () => _answerPictureQuiz(item),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildHowToPlay() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 10),
            blurRadius: 20,
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '怎么玩更顺手',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: kTitleTextColor,
            ),
          ),
          SizedBox(height: 12),
          _TipRow(emoji: '1', text: '先滑动大卡片，听字母音和两个例词。'),
          _TipRow(emoji: '2', text: '再点“中文提示”，让孩子知道嘴巴怎么发音。'),
          _TipRow(emoji: '3', text: '最后玩两个小游戏，把声音和图片、字母连起来。'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: PageHeader(
              title: 'ABC Sounds',
              primaryColor: const Color(0xFFFFC870),
              secondaryColor: const Color(0xFFFF7B72),
              offset: _offset,
              onTap: () => _playAssetOrFallback(
                'assets/audio/tts/letter_sounds/intro/welcome.mp3',
                () => _speakChinese('字母发音乐园，轻轻一点就可以开始。'),
              ),
            ),
          ),
          SliverToBoxAdapter(child: _buildHeroCard()),
          SliverToBoxAdapter(child: _buildStageSelector()),
          SliverToBoxAdapter(child: _buildStageCard()),
          SliverToBoxAdapter(child: _buildLetterCarousel()),
          SliverToBoxAdapter(child: _buildDots()),
          SliverToBoxAdapter(child: _buildLetterQuiz()),
          SliverToBoxAdapter(child: _buildPictureQuiz()),
          SliverToBoxAdapter(child: _buildHowToPlay()),
        ],
      ),
    );
  }
}

class _HeroBubble extends StatelessWidget {
  final String label;
  final Color color;
  final double size;

  const _HeroBubble({
    required this.label,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.34),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _HeroAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _HeroAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.72),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: kPrimaryColor),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: kTitleTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LetterCard extends StatelessWidget {
  final LetterSoundItem item;
  final bool selected;
  final VoidCallback onPlaySound;
  final VoidCallback onPlayPrimary;
  final VoidCallback onPlaySecondary;
  final VoidCallback onPlayPrompt;
  final VoidCallback onPlayChant;

  const _LetterCard({
    required this.item,
    required this.selected,
    required this.onPlaySound,
    required this.onPlayPrimary,
    required this.onPlaySecondary,
    required this.onPlayPrompt,
    required this.onPlayChant,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            item.accentColor.withValues(alpha: 0.9),
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: item.accentColor.withValues(alpha: selected ? 0.24 : 0.12),
            blurRadius: selected ? 24 : 14,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  item.phonicsText,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const Spacer(),
              IconButton.filledTonal(
                onPressed: onPlaySound,
                icon: const Icon(Icons.volume_up_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.22),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.letter,
            style: const TextStyle(
              fontSize: 78,
              height: 1,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.soundCue,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _WordChip(
                  emoji: item.primaryEmoji,
                  label: item.primaryWord,
                  onTap: onPlayPrimary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _WordChip(
                  emoji: item.secondaryEmoji,
                  label: item.secondaryWord,
                  onTap: onPlaySecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              item.chinesePrompt,
              style: const TextStyle(
                fontSize: 14,
                height: 1.45,
                color: kBodyTextColor,
              ),
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPlayPrompt,
                  icon: const Icon(Icons.record_voice_over_rounded),
                  label: const Text('中文提示'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white70),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onPlayChant,
                  icon: const Icon(Icons.music_note_rounded),
                  label: const Text('一起念'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: item.accentColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WordChip extends StatelessWidget {
  final String emoji;
  final String label;
  final VoidCallback onTap;

  const _WordChip({
    required this.emoji,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.82),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: kTitleTextColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color colorA;
  final Color colorB;
  final IconData actionIcon;
  final VoidCallback onAction;
  final Widget child;

  const _GameCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.colorA,
    required this.colorB,
    required this.actionIcon,
    required this.onAction,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          colors: [colorA, colorB],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colorB.withValues(alpha: 0.16),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: kTitleTextColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.45,
                        color: kBodyTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              IconButton.filled(
                onPressed: onAction,
                icon: Icon(actionIcon),
              ),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _QuizBubble extends StatelessWidget {
  final String label;
  final String emoji;
  final Color color;
  final VoidCallback onTap;

  const _QuizBubble({
    required this.label,
    required this.emoji,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Ink(
          width: 96,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: color.withValues(alpha: 0.4), width: 1.4),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PictureChoice extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _PictureChoice({
    required this.emoji,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Ink(
          width: 108,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.14),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 34)),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: kTitleTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  final String emoji;
  final String text;

  const _TipRow({
    required this.emoji,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: kTitleTextColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                height: 1.45,
                color: kBodyTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
