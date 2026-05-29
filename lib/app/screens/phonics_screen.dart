import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';

import '../constant.dart';
import '../controllers/phonics_controller.dart';
import '../models/phonics_item.dart';
import '../widgets/page_header.dart';

const Map<String, String> _phonicsSymbols = {
  'Long ee': '/iː/',
  'Short i': '/ɪ/',
  'Little e': '/e/',
  'Open a': '/æ/',
  'Long er': '/ɜː/',
  'Lazy uh': '/ə/',
  'Cup sound': '/ʌ/',
  'Long oo': '/uː/',
  'Short oo': '/ʊ/',
  'Long aw': '/ɔː/',
  'Short o': '/ɒ/',
  'Long aah': '/ɑː/',
  'A slide': '/eɪ/',
  'I slide': '/aɪ/',
  'Toy sound': '/ɔɪ/',
  'Wow sound': '/aʊ/',
  'Go sound': '/oʊ/',
  'Ear sound': '/ɪə/',
  'Air sound': '/eə/',
  'Tour sound': '/ʊə/',
  'Pop p': '/p/',
  'Tap t': '/t/',
  'Kick k': '/k/',
  'Big b': '/b/',
  'Drum d': '/d/',
  'Go g': '/g/',
  'Fan f': '/f/',
  'Vroom v': '/v/',
  'Snake s': '/s/',
  'Bee z': '/z/',
  'Shh sound': '/ʃ/',
  'Zh buzz': '/ʒ/',
  'Thin th': '/θ/',
  'This th': '/ð/',
  'Hot h': '/h/',
  'Run r': '/r/',
  'Ch sound': '/tʃ/',
  'Tr sound': '/tr/',
  'Ts sound': '/ts/',
  'J sound': '/dʒ/',
  'Dr sound': '/dr/',
  'Dz sound': '/dz/',
  'Mmm sound': '/m/',
  'Nnn sound': '/n/',
  'Ng sound': '/ŋ/',
  'Light l': '/l/',
  'Y sound': '/j/',
  'W sound': '/w/',
};

const Map<String, String> _phonicsVoices = {
  'Long ee': 'ee',
  'Short i': 'ih',
  'Little e': 'eh',
  'Open a': 'a',
  'Long er': 'er',
  'Lazy uh': 'uh',
  'Cup sound': 'uh',
  'Long oo': 'oo',
  'Short oo': 'u',
  'Long aw': 'aw',
  'Short o': 'o',
  'Long aah': 'aah',
  'A slide': 'ay',
  'I slide': 'eye',
  'Toy sound': 'oy',
  'Wow sound': 'ow',
  'Go sound': 'oh',
  'Ear sound': 'ear',
  'Air sound': 'air',
  'Tour sound': 'oor',
  'Pop p': 'puh',
  'Tap t': 'tuh',
  'Kick k': 'kuh',
  'Big b': 'buh',
  'Drum d': 'duh',
  'Go g': 'guh',
  'Fan f': 'fff',
  'Vroom v': 'vvv',
  'Snake s': 'sss',
  'Bee z': 'zzz',
  'Shh sound': 'sh',
  'Zh buzz': 'zh',
  'Thin th': 'th',
  'This th': 'th',
  'Hot h': 'h',
  'Run r': 'rrr',
  'Ch sound': 'ch',
  'Tr sound': 'tr',
  'Ts sound': 'ts',
  'J sound': 'j',
  'Dr sound': 'dr',
  'Dz sound': 'dz',
  'Mmm sound': 'mmm',
  'Nnn sound': 'nnn',
  'Ng sound': 'ng',
  'Light l': 'lll',
  'Y sound': 'y',
  'W sound': 'w',
};

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

  String _symbolOf(PhonicsItem item) =>
      _phonicsSymbols[item.title] ?? item.symbol;

  String _directVoiceOf(PhonicsItem item) =>
      _phonicsVoices[item.title] ?? item.soundCue.split(',').first;

  Future<void> _playIntro() async {
    await _playAssetOrSpeak(
      'assets/audio/tts/phonics/intro/welcome.mp3',
      () => _speakEnglish(
        'Welcome to phonics. Tap the sound first, then hear the word, and say it with me.',
        rate: 0.34,
      ),
    );
  }

  Future<void> _playDirectSound(PhonicsItem item) async {
    await _playAssetOrSpeak(
      item.soundAudioAsset,
      () => _speakEnglish(
        _directVoiceOf(item),
        rate: 0.34,
      ),
    );
  }

  void _showSoundSheet(PhonicsItem item) {
    _playDirectSound(item);
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
                            _symbolOf(item),
                            style: GoogleFonts.robotoMono(
                              fontSize: 40,
                              fontWeight: FontWeight.w800,
                              color: kTitleTextColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.title,
                            style: GoogleFonts.notoSans(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: kTitleTextColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.exampleWord,
                            style: GoogleFonts.notoSans(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: kTitleTextColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.examplePhrase,
                            style: GoogleFonts.notoSans(
                              fontSize: 16,
                              height: 1.4,
                              color: kBodyTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'How We Learn',
                      style: GoogleFonts.notoSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: kTitleTextColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      item.chinesePrompt,
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
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        'Mouth tip: ${item.mouthTip}',
                        style: GoogleFonts.notoSans(
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
                          onPressed: () => _playDirectSound(item),
                          icon: const Icon(Icons.volume_up),
                          label: const Text('听音标'),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: () => _playAssetOrSpeak(
                            item.wordAudioAsset,
                            () => _speakEnglish(item.exampleWord),
                          ),
                          icon: const Icon(Icons.music_note),
                          label: const Text('听例词'),
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
                          label: const Text('跟我说'),
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
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Phonics',
            style: GoogleFonts.notoSans(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: kTitleTextColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '这次把音标卡片改得更直观了。你会先看到标准音标，再直接听这个音。',
            style: GoogleFonts.notoSans(
              fontSize: 16,
              height: 1.5,
              color: kBodyTextColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildStepTile(Icons.volume_up_outlined, '1. 先听这个音'),
          _buildStepTile(Icons.menu_book_outlined, '2. 再看例词'),
          _buildStepTile(Icons.record_voice_over_outlined, '3. 最后跟着说'),
          const SizedBox(height: 14),
          FilledButton.tonalIcon(
            onPressed: _playIntro,
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

  Widget _buildSectionHeader(PhonicsGroup group) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            group.title,
            style: GoogleFonts.notoSans(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: kTitleTextColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            group.subtitle,
            style: GoogleFonts.notoSans(
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
                        _symbolOf(item),
                        style: GoogleFonts.robotoMono(
                          fontSize: 24,
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
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: kTitleTextColor,
                  ),
                ),
                const Spacer(),
                Text(
                  _directVoiceOf(item),
                  style: GoogleFonts.notoSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: kTitleTextColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.exampleWord,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
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
          onTap: _playIntro,
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
              childAspectRatio: 0.88,
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
