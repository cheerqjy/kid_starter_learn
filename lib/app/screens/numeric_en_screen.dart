import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';

import '../constant.dart';
import '../controllers/numeric_en_controller.dart';
import '../models/numeric_en_model.dart';
import '../services/learning_progress_service.dart';
import '../widgets/page_header.dart';

class NumericEnScreen extends StatefulWidget {
  final String title;
  final Color primaryColor;
  final Color secondaryColor;

  const NumericEnScreen({
    Key? key,
    required this.title,
    required this.primaryColor,
    required this.secondaryColor,
  }) : super(key: key);

  @override
  State<NumericEnScreen> createState() => _NumericEnScreenState();
}

class _NumericEnScreenState extends State<NumericEnScreen> {
  final ScrollController _scrollController = ScrollController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterTts _tts = FlutterTts();
  double _offset = 0;

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

  Future<void> _speakNumber(NumericEnModel item) async {
    HapticFeedback.selectionClick();
    await LearningProgressService.incrementNumbersPracticed();
    for (final assetPath in [
      if (item.audio != null) item.audio!,
      item.generatedAudioAsset
    ]) {
      try {
        await _audioPlayer.stop();
        await _audioPlayer.setAsset(assetPath);
        await _audioPlayer.play();
        return;
      } catch (_) {}
    }

    await _tts.stop();
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.42);
    await _tts.speak(item.englishWord);
  }

  Future<void> _playIntro() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.setAsset('assets/audio/tts/numbers/intro.mp3');
      await _audioPlayer.play();
    } catch (_) {
      await _tts.stop();
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.4);
      await _tts.speak('Tap a number and listen.');
    }
  }

  Widget _buildIntroCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          colors: [Color(0xFFE3F6E6), Color(0xFFFFF5D8)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Count and Tap',
            style: GoogleFonts.notoSans(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: kTitleTextColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '先认识数字，再听英文读法。现在已经从 0 扩展到 20，前面更简单，后面慢慢加一点。',
            style: GoogleFonts.notoSans(
              fontSize: 15,
              height: 1.5,
              color: kBodyTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberCard(NumericEnModel item, int index) {
    final color = getIndexColor(index);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => _speakNumber(item),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.14),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.text,
                        style: TextStyle(
                          fontSize: 46,
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                      ),
                    ),
                    Icon(Icons.volume_up_rounded, color: color),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.englishWord,
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: kTitleTextColor,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    item.visual,
                    style: GoogleFonts.notoSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: kBodyTextColor,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.tonalIcon(
                    onPressed: () => _speakNumber(item),
                    icon: const Icon(Icons.volume_up_rounded),
                    label: const Text('Play'),
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
          SliverToBoxAdapter(child: _buildIntroCard()),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.92,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) =>
                    _buildNumberCard(numericEnList[index], index),
                childCount: numericEnList.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
