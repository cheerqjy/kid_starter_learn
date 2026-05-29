import 'package:flutter/material.dart';

import '../utils/audio_keys.dart';

class LetterSoundItem {
  final String letter;
  final String phonicsText;
  final String soundCue;
  final String primaryWord;
  final String secondaryWord;
  final String primaryEmoji;
  final String secondaryEmoji;
  final String videoUrl;
  final String chinesePrompt;
  final String chant;
  final Color accentColor;

  const LetterSoundItem({
    required this.letter,
    required this.phonicsText,
    required this.soundCue,
    required this.primaryWord,
    required this.secondaryWord,
    required this.primaryEmoji,
    required this.secondaryEmoji,
    required this.videoUrl,
    required this.chinesePrompt,
    required this.chant,
    required this.accentColor,
  });

  String get _audioKey => slugifyKey(letter);

  String get soundAudioAsset =>
      'assets/audio/tts/letter_sounds/sound/$_audioKey.mp3';

  String get primaryWordAudioAsset =>
      'assets/audio/tts/letter_sounds/word/$_audioKey-1.mp3';

  String get secondaryWordAudioAsset =>
      'assets/audio/tts/letter_sounds/word/$_audioKey-2.mp3';

  String get chantAudioAsset =>
      'assets/audio/tts/letter_sounds/chant/$_audioKey.mp3';

  String get promptAudioAsset =>
      'assets/audio/tts/letter_sounds/prompt/$_audioKey.mp3';
}

class LetterSoundStage {
  final String code;
  final String title;
  final String subtitle;
  final String chinesePrompt;
  final Color primaryColor;
  final Color secondaryColor;
  final List<LetterSoundItem> items;

  const LetterSoundStage({
    required this.code,
    required this.title,
    required this.subtitle,
    required this.chinesePrompt,
    required this.primaryColor,
    required this.secondaryColor,
    required this.items,
  });

  String get _audioKey => slugifyKey(code);

  String get introAudioAsset =>
      'assets/audio/tts/letter_sounds/intro/$_audioKey.mp3';
}
