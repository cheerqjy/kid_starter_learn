import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';

import '../constant.dart';
import '../controllers/prepositions_controller.dart';
import '../models/preposition_scene.dart';
import '../widgets/page_header.dart';

class PrepositionsScreen extends StatefulWidget {
  const PrepositionsScreen({Key? key}) : super(key: key);

  @override
  State<PrepositionsScreen> createState() => _PrepositionsScreenState();
}

class _PrepositionsScreenState extends State<PrepositionsScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();
  late final AnimationController _movementController;
  double _offset = 0;
  int _index = 0;

  PrepositionScene get _scene => prepositionScenes[_index];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _movementController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playGuide();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _movementController.dispose();
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
    await _tts.speak(text);
  }

  Future<void> _speakChinese(String text) async {
    HapticFeedback.selectionClick();
    await _tts.stop();
    await _tts.setLanguage('zh-CN');
    await _tts.setSpeechRate(0.42);
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

  Future<void> _playGuide() async {
    await _playAssetOrSpeak(
      'assets/audio/tts/prepositions/intro/welcome.mp3',
      () => _speakEnglish(
        'Welcome to prepositions. First watch where the ball goes, then hear the word and the sentence.',
        rate: 0.34,
      ),
    );
  }

  void _goToScene(int nextIndex) {
    setState(() {
      _index = nextIndex;
    });
    _movementController
      ..reset()
      ..repeat(reverse: true);
    _playAssetOrSpeak(
      prepositionScenes[nextIndex].wordAudioAsset,
      () => _speakEnglish(prepositionScenes[nextIndex].title),
    );
  }

  Widget _buildIntroCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF7CC), Color(0xFFD9F2FF)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Where Is It?',
            style: GoogleFonts.notoSans(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: kTitleTextColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '这次把介词场景做得更直观了。先看动画，再听英文，再听中文解释。',
            style: GoogleFonts.notoSans(
              fontSize: 16,
              height: 1.5,
              color: kBodyTextColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildStepTile(Icons.visibility_outlined, '1. 先看小球在哪里'),
          _buildStepTile(Icons.volume_up_outlined, '2. 听介词和句子'),
          _buildStepTile(Icons.record_voice_over_outlined, '3. 再听中文解释'),
          const SizedBox(height: 14),
          FilledButton.tonalIcon(
            onPressed: _playGuide,
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
              color: Colors.white.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFF3B82F6)),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.notoSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: kTitleTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSceneCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: kActiveShadowColor,
            blurRadius: 24,
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
                      _scene.title,
                      style: GoogleFonts.notoSans(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: kTitleTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _scene.chineseTitle,
                      style: GoogleFonts.notoSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: kBodyTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                onPressed: () => _goToScene(
                  (_index - 1 + prepositionScenes.length) %
                      prepositionScenes.length,
                ),
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: () =>
                    _goToScene((_index + 1) % prepositionScenes.length),
                icon: const Icon(Icons.arrow_forward),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 260,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [Color(0xFFEAF6FF), Color(0xFFFFF9EF)],
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: AnimatedBuilder(
                animation: _movementController,
                builder: (context, child) {
                  return _buildAnimatedScene(
                      _scene.type, _movementController.value);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _scene.exampleSentence,
            style: GoogleFonts.notoSans(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: kTitleTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _scene.chinesePrompt,
            style: GoogleFonts.notoSans(
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
              color: const Color(0xFFF5F8FF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              _scene.playHint,
              style: GoogleFonts.notoSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: kBodyTextColor,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.tonalIcon(
                onPressed: () => _playAssetOrSpeak(
                  _scene.wordAudioAsset,
                  () => _speakEnglish(_scene.title),
                ),
                icon: const Icon(Icons.volume_up),
                label: const Text('听介词'),
              ),
              FilledButton.tonalIcon(
                onPressed: () => _playAssetOrSpeak(
                  _scene.phraseAudioAsset,
                  () => _speakEnglish(_scene.exampleSentence, rate: 0.34),
                ),
                icon: const Icon(Icons.music_note),
                label: const Text('听句子'),
              ),
              FilledButton.tonalIcon(
                onPressed: () => _playAssetOrSpeak(
                  _scene.promptAudioAsset,
                  () => _speakChinese(_scene.chinesePrompt),
                ),
                icon: const Icon(Icons.record_voice_over),
                label: const Text('中文解释'),
              ),
              FilledButton.tonalIcon(
                onPressed: _playGuide,
                icon: const Icon(Icons.play_circle_fill),
                label: const Text('再听引导'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedScene(PrepositionSceneType type, double progress) {
    switch (type) {
      case PrepositionSceneType.inBox:
      case PrepositionSceneType.onBox:
      case PrepositionSceneType.nearBox:
      case PrepositionSceneType.aboveBox:
      case PrepositionSceneType.underBox:
      case PrepositionSceneType.inFrontOfBox:
      case PrepositionSceneType.behindBox:
      case PrepositionSceneType.intoBox:
      case PrepositionSceneType.outOfBox:
      case PrepositionSceneType.aroundBox:
        return _buildBoxScene(type, progress);
      case PrepositionSceneType.betweenBoxes:
        return _buildBetweenScene(progress);
      case PrepositionSceneType.throughTunnel:
        return _buildTunnelScene(progress);
      case PrepositionSceneType.acrossRiver:
        return _buildAcrossScene(progress);
      default:
        return _buildBoxScene(PrepositionSceneType.onBox, progress);
    }
  }

  Widget _buildBoxScene(PrepositionSceneType type, double progress) {
    final wave = math.sin(progress * math.pi * 2) * 0.02;
    Alignment alignment = Alignment.center;
    bool hideBehind = false;

    switch (type) {
      case PrepositionSceneType.inBox:
        alignment = Alignment(0, 0.12 + wave);
        break;
      case PrepositionSceneType.onBox:
        alignment = Alignment(0, -0.34 + wave);
        break;
      case PrepositionSceneType.nearBox:
        alignment = Alignment(-0.72, 0.02 + wave);
        break;
      case PrepositionSceneType.aboveBox:
        alignment = Alignment(0, -0.72 + wave);
        break;
      case PrepositionSceneType.underBox:
        alignment = Alignment(0, 0.48 + wave);
        break;
      case PrepositionSceneType.inFrontOfBox:
        alignment = Alignment(0, 0.32 + wave);
        break;
      case PrepositionSceneType.behindBox:
        alignment = Alignment(0, 0.02 + wave);
        hideBehind = true;
        break;
      case PrepositionSceneType.intoBox:
        alignment = Alignment(-0.85 + progress * 0.85, 0.02 + wave);
        break;
      case PrepositionSceneType.outOfBox:
        alignment = Alignment(progress * 0.88, 0.02 + wave);
        break;
      case PrepositionSceneType.aroundBox:
        final angle = progress * math.pi * 2;
        alignment = Alignment(math.cos(angle) * 0.78, math.sin(angle) * 0.52);
        break;
      default:
        break;
    }

    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          bottom: 28,
          child: Container(height: 16, color: const Color(0xFFE2D3B8)),
        ),
        Align(
          alignment: const Alignment(0, 0.06),
          child: Container(
            width: 140,
            height: 130,
            decoration: BoxDecoration(
              color: const Color(0xFF6AA9FF),
              borderRadius: BorderRadius.circular(24),
            ),
            child: type == PrepositionSceneType.inBox
                ? Align(
                    alignment: const Alignment(0, -0.44),
                    child: Container(
                      width: 124,
                      height: 18,
                      decoration: BoxDecoration(
                        color: const Color(0xFF8BBEFF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  )
                : null,
          ),
        ),
        if (!hideBehind) Align(alignment: alignment, child: _buildBall()),
        if (hideBehind)
          Stack(
            children: [
              Align(alignment: alignment, child: _buildBall()),
              Align(
                alignment: const Alignment(0, 0.06),
                child: Container(
                  width: 140,
                  height: 130,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6AA9FF),
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildBetweenScene(double progress) {
    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          bottom: 28,
          child: Container(height: 16, color: const Color(0xFFE2D3B8)),
        ),
        Align(alignment: const Alignment(-0.5, 0.05), child: _buildMiniBox()),
        Align(alignment: const Alignment(0.5, 0.05), child: _buildMiniBox()),
        Align(
          alignment: Alignment(0, math.sin(progress * math.pi * 2) * 0.03),
          child: _buildBall(),
        ),
      ],
    );
  }

  Widget _buildAcrossScene(double progress) {
    return Stack(
      children: [
        Align(
          alignment: const Alignment(0, 0.15),
          child: Container(
            width: 280,
            height: 74,
            decoration: BoxDecoration(
              color: const Color(0xFF88D4FF),
              borderRadius: BorderRadius.circular(40),
            ),
          ),
        ),
        Align(
          alignment: Alignment(-0.86 + progress * 1.72, 0.15),
          child: _buildBall(),
        ),
      ],
    );
  }

  Widget _buildTunnelScene(double progress) {
    return Stack(
      children: [
        Align(
          alignment: const Alignment(0, 0.22),
          child: Container(
            width: 290,
            height: 110,
            decoration: BoxDecoration(
              color: const Color(0xFF7E879C),
              borderRadius: BorderRadius.circular(60),
            ),
          ),
        ),
        Align(
          alignment: const Alignment(0, 0.28),
          child: Container(
            width: 200,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF6FF),
              borderRadius: BorderRadius.circular(40),
            ),
          ),
        ),
        Align(
          alignment: Alignment(-0.72 + progress * 1.44, 0.28),
          child: _buildBall(),
        ),
      ],
    );
  }

  Widget _buildMiniBox() {
    return Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        color: const Color(0xFF6AA9FF),
        borderRadius: BorderRadius.circular(18),
      ),
    );
  }

  static Widget _buildBall() {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: const Color(0xFFFF6B5E),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
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
              title: 'Where?',
              primaryColor: const Color(0xFFFFD56C),
              secondaryColor: const Color(0xFF5CB8FF),
              offset: _offset,
              onTap: _playGuide,
            ),
          ),
          SliverToBoxAdapter(child: _buildIntroCard()),
          SliverToBoxAdapter(child: _buildSceneCard()),
        ],
      ),
    );
  }
}
