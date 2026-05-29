import 'package:flutter/material.dart';

import '../utils/audio_keys.dart';

class PhonicsItem {
  final String symbol;
  final String title;
  final String exampleWord;
  final String examplePhrase;
  final String soundCue;
  final String chinesePrompt;
  final String mouthTip;
  final Color backgroundColor;

  const PhonicsItem({
    required this.symbol,
    required this.title,
    required this.exampleWord,
    required this.examplePhrase,
    required this.soundCue,
    required this.chinesePrompt,
    required this.mouthTip,
    required this.backgroundColor,
  });

  String get _audioKey => slugifyKey(title);

  String get wordAudioAsset => 'assets/audio/tts/phonics/word/$_audioKey.mp3';

  String get phraseAudioAsset =>
      'assets/audio/tts/phonics/phrase/$_audioKey.mp3';

  String get promptAudioAsset =>
      'assets/audio/tts/phonics/prompt/$_audioKey.mp3';
}

class PhonicsGroup {
  final String title;
  final String subtitle;
  final Color primaryColor;
  final Color secondaryColor;
  final List<PhonicsItem> items;

  const PhonicsGroup({
    required this.title,
    required this.subtitle,
    required this.primaryColor,
    required this.secondaryColor,
    required this.items,
  });
}
