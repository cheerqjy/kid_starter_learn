import 'package:flutter/material.dart';

import '../utils/audio_keys.dart';

class VocabularyItem {
  final String title;
  final String assetPath;
  final Color backgroundColor;

  const VocabularyItem({
    required this.title,
    required this.assetPath,
    required this.backgroundColor,
  });

  bool get isSvg => assetPath.toLowerCase().endsWith('.svg');

  String get audioAsset =>
      'assets/audio/tts/vocabulary/${slugifyKey(title)}.mp3';
}

class VocabularyModule {
  final String homeTitle;
  final String screenTitle;
  final Color primaryColor;
  final Color secondaryColor;
  final double homeFontSize;
  final double homeLetterSpacing;
  final int homeMaxLines;
  final List<VocabularyItem> items;

  const VocabularyModule({
    required this.homeTitle,
    required this.screenTitle,
    required this.primaryColor,
    required this.secondaryColor,
    required this.items,
    this.homeFontSize = 72.0,
    this.homeLetterSpacing = 3.0,
    this.homeMaxLines = 1,
  });
}
