import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';

import '../constant.dart';
import '../services/learning_progress_service.dart';
import '../utils/audio_keys.dart';
import '../widgets/page_header.dart';

class ShapesScreen extends StatefulWidget {
  final String title;
  final Color primaryColor;
  final Color secondaryColor;

  const ShapesScreen({
    Key? key,
    required this.title,
    required this.primaryColor,
    required this.secondaryColor,
  }) : super(key: key);

  @override
  State<ShapesScreen> createState() => _ShapesScreenState();
}

class _ShapesScreenState extends State<ShapesScreen> {
  final _scrollController = ScrollController();
  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();
  double _offset = 0;

  final _shapes = const [
    ('circle', '圆形', '⚪'),
    ('square', '正方形', '🟦'),
    ('triangle', '三角形', '🔺'),
    ('rectangle', '长方形', '▭'),
    ('star', '星形', '⭐'),
    ('heart', '爱心', '💛'),
    ('oval', '椭圆形', '🥚'),
    ('diamond', '菱形', '🔷'),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playIntro();
    });
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

  Future<void> _playIntro() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.setAsset('assets/audio/tts/shapes/intro.mp3');
      await _audioPlayer.play();
      return;
    } catch (_) {}

    await _tts.stop();
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.4);
    await _tts.speak('Tap a shape and listen.');
  }

  Future<void> _speakShape((String, String, String) shape) async {
    await LearningProgressService.incrementShapesPracticed();
    try {
      await _audioPlayer.stop();
      await _audioPlayer
          .setAsset('assets/audio/tts/shapes/${slugifyKey(shape.$1)}.mp3');
      await _audioPlayer.play();
      return;
    } catch (_) {}

    await _tts.stop();
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.4);
    await _tts.speak(shape.$1);
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
              title: widget.title,
              primaryColor: widget.primaryColor,
              secondaryColor: widget.secondaryColor,
              offset: _offset,
              onTap: _playIntro,
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 8, 20, 18),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFE2E0), Color(0xFFFFF6D8)],
                ),
              ),
              child: Text(
                'Shapes 也补齐了。点一张卡就读英文，先从圆形、正方形、三角形开始。',
                style: GoogleFonts.notoSans(
                  fontSize: 15,
                  height: 1.5,
                  color: kBodyTextColor,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.95,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final shape = _shapes[index];
                  final color = getIndexColor(index);
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () => _speakShape(shape),
                      child: Ink(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.12),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              const Spacer(),
                              Text(shape.$3,
                                  style: const TextStyle(fontSize: 52)),
                              const SizedBox(height: 12),
                              Text(
                                shape.$1,
                                style: GoogleFonts.notoSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: kTitleTextColor,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                shape.$2,
                                style: GoogleFonts.notoSans(
                                  fontSize: 14,
                                  color: kBodyTextColor,
                                ),
                              ),
                              const SizedBox(height: 10),
                              FilledButton.tonalIcon(
                                onPressed: () => _speakShape(shape),
                                icon: const Icon(Icons.volume_up_rounded),
                                label: const Text('Play'),
                              ),
                              const Spacer(),
                              Icon(Icons.volume_up_rounded, color: color),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
                childCount: _shapes.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
