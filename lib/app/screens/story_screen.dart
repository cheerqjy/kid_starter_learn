import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';

import '../constant.dart';
import '../services/learning_progress_service.dart';
import '../utils/audio_keys.dart';
import '../widgets/page_header.dart';

class StoriesScreen extends StatefulWidget {
  final String title;
  final Color primaryColor;
  final Color secondaryColor;

  const StoriesScreen({
    Key? key,
    required this.title,
    required this.primaryColor,
    required this.secondaryColor,
  }) : super(key: key);

  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  final _scrollController = ScrollController();
  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();
  double _offset = 0;

  final _stories = const [
    (
      emoji: '🐱',
      title: 'The Little Cat',
      line1: 'This is a cat.',
      line2: 'The cat is on the mat.',
      line3: 'The cat says meow.',
      chinese: '小猫在垫子上，小朋友先听，再跟读。'
    ),
    (
      emoji: '🎈',
      title: 'The Red Ball',
      line1: 'I see a red ball.',
      line2: 'The ball is big and round.',
      line3: 'The ball can bounce.',
      chinese: '红色的球大大的、圆圆的，还会跳。'
    ),
    (
      emoji: '🐻',
      title: 'Bear in the Box',
      line1: 'The bear is in the box.',
      line2: 'The bear looks out.',
      line3: 'Hello, little bear.',
      chinese: '这张卡可以顺便复习 in 和 box。'
    ),
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
      await _audioPlayer.setAsset('assets/audio/tts/stories/intro.mp3');
      await _audioPlayer.play();
      return;
    } catch (_) {}

    await _tts.stop();
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.38);
    await _tts.speak('Tap a story card and listen.');
  }

  Future<void> _speakStory(
    ({
      String emoji,
      String title,
      String line1,
      String line2,
      String line3,
      String chinese,
    }) story,
  ) async {
    await LearningProgressService.incrementStoriesPlayed();
    final storyKey = slugifyKey(story.title);
    try {
      await _audioPlayer.stop();
      await _audioPlayer.setAsset('assets/audio/tts/stories/$storyKey.mp3');
      await _audioPlayer.play();
      return;
    } catch (_) {}

    await _tts.stop();
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.38);
    await _tts.speak('${story.line1} ${story.line2} ${story.line3}');
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
                  colors: [Color(0xFFE8F1FF), Color(0xFFF6ECFF)],
                ),
              ),
              child: Text(
                'Stories 现在已经补上了。每张故事卡都很短，适合 3-6 岁孩子反复听、反复说。',
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
            sliver: SliverList.separated(
              itemCount: _stories.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final story = _stories[index];
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () => _speakStory(story),
                    child: Ink(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(story.emoji,
                                  style: const TextStyle(fontSize: 38)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  story.title,
                                  style: GoogleFonts.notoSans(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: kTitleTextColor,
                                  ),
                                ),
                              ),
                              IconButton.filled(
                                onPressed: () => _speakStory(story),
                                icon: const Icon(Icons.volume_up_rounded),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${story.line1}\n${story.line2}\n${story.line3}',
                            style: GoogleFonts.notoSans(
                              fontSize: 16,
                              height: 1.7,
                              color: kTitleTextColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            story.chinese,
                            style: GoogleFonts.notoSans(
                              fontSize: 14,
                              height: 1.5,
                              color: kBodyTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
