import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';

import '../constant.dart';
import '../controllers/phonics_controller.dart';
import '../models/phonics_item.dart';
import '../widgets/page_header.dart';

class PhonicsScreen extends StatefulWidget {
  const PhonicsScreen({Key? key}) : super(key: key);

  @override
  State<PhonicsScreen> createState() => _PhonicsScreenState();
}

class _PhonicsScreenState extends State<PhonicsScreen> {
  final ScrollController _scrollController = ScrollController();
  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();
  double _offset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _audioPlayer.dispose();
    _tts.stop();
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _offset = _scrollController.hasClients ? _scrollController.offset : 0;
    });
  }

  Future<void> _speakEnglish(String text, {double rate = 0.38}) async {
    HapticFeedback.selectionClick();
    await _tts.stop();
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(rate);
    await _tts.setPitch(1.0);
    await _tts.speak(text);
  }

  Future<void> _speakChinese(String text) async {
    HapticFeedback.selectionClick();
    await _tts.stop();
    await _tts.setLanguage('zh-CN');
    await _tts.setSpeechRate(0.42);
    await _tts.setPitch(1.0);
    await _tts.speak(text);
  }

  Future<void> _playAssetOrSpeak(
    String assetPath,
    Future<void> Function() fallback,
  ) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.setAsset(assetPath);
      await _audioPlayer.play();
    } catch (_) {
      await fallback();
    }
  }

  void _showSoundSheet(PhonicsItem item) {
    _playAssetOrSpeak(
      item.wordAudioAsset,
      () => _speakEnglish(item.exampleWord),
    );
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 56,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: item.backgroundColor,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.symbol,
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w800,
                              color: kTitleTextColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: kTitleTextColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.exampleWord,
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: kTitleTextColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.examplePhrase,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.4,
                              color: kBodyTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'How We Learn',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: kTitleTextColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      item.chinesePrompt,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: kBodyTextColor,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        'Mouth tip: ${item.mouthTip}',
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.45,
                          color: kBodyTextColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        FilledButton.tonalIcon(
                          onPressed: () => _playAssetOrSpeak(
                            item.promptAudioAsset,
                            () => _speakChinese(item.chinesePrompt),
                          ),
                          icon: const Icon(Icons.record_voice_over),
                          label: const Text('中文提示'),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: () => _playAssetOrSpeak(
                            item.wordAudioAsset,
                            () => _speakEnglish(item.soundCue),
                          ),
                          icon: const Icon(Icons.volume_up),
                          label: const Text('听声音'),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: () => _playAssetOrSpeak(
                            item.wordAudioAsset,
                            () => _speakEnglish(item.exampleWord),
                          ),
                          icon: const Icon(Icons.music_note),
                          label: const Text('听单词'),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: () => _playAssetOrSpeak(
                            item.phraseAudioAsset,
                            () => _speakEnglish(
                              'Listen and say. ${item.examplePhrase}',
                              rate: 0.34,
                            ),
                          ),
                          icon: const Icon(Icons.mic),
                          label: const Text('跟我读'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIntroCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF0D9), Color(0xFFFFD6CC)],
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
          const Text(
            'Sound Land',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: kTitleTextColor,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Little learners do not need to memorize symbols first. We listen, watch, copy, and play.',
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: kBodyTextColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildStepTile(Icons.remove_red_eye_outlined, '1. Watch the mouth'),
          _buildStepTile(Icons.volume_up_outlined, '2. Hear the sound'),
          _buildStepTile(Icons.record_voice_over_outlined, '3. Say it back'),
          const SizedBox(height: 14),
          FilledButton.tonalIcon(
            onPressed: () => _speakChinese(
              '欢迎来到发音乐园。先看嘴巴，再听声音，最后跟着说。',
            ),
            icon: const Icon(Icons.play_circle_fill),
            label: const Text('播放学习引导'),
          ),
        ],
      ),
    );
  }

  Widget _buildStepTile(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: kPrimaryColor),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: kTitleTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(PhonicsGroup group) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            group.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: kTitleTextColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            group.subtitle,
            style: const TextStyle(
              fontSize: 15,
              height: 1.4,
              color: kBodyTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoundCard(PhonicsItem item, PhonicsGroup group) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => _showSoundSheet(item),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              colors: [item.backgroundColor, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: group.secondaryColor.withValues(alpha: 0.18),
                offset: const Offset(0, 10),
                blurRadius: 22,
              ),
            ],
            border: Border.all(
              color: group.primaryColor.withValues(alpha: 0.7),
              width: 1.2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.symbol,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: kTitleTextColor,
                        ),
                      ),
                    ),
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: group.secondaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.volume_up,
                        size: 18,
                        color: group.secondaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: kTitleTextColor,
                  ),
                ),
                const Spacer(),
                Text(
                  item.exampleWord,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: kTitleTextColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.mouthTip,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: kBodyTextColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final slivers = <Widget>[
      SliverToBoxAdapter(
        child: PageHeader(
          title: 'Phonics',
          primaryColor: const Color(0xFFFFC46B),
          secondaryColor: const Color(0xFFFF8A65),
          offset: _offset,
          onTap: () => _speakChinese('发音乐园，轻轻一点开始学习。'),
        ),
      ),
      SliverToBoxAdapter(child: _buildIntroCard()),
    ];

    for (final group in phonicsGroups) {
      slivers.add(SliverToBoxAdapter(child: _buildSectionHeader(group)));
      slivers.add(
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.86,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildSoundCard(group.items[index], group),
              childCount: group.items.length,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: slivers,
      ),
    );
  }
}
