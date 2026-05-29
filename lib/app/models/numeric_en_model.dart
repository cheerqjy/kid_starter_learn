import '../utils/audio_keys.dart';

class NumericEnModel {
  final String text;
  final String englishWord;
  final int value;
  final String visual;
  final String? audio;

  NumericEnModel({
    required this.text,
    required this.englishWord,
    required this.value,
    required this.visual,
    this.audio,
  });

  String get generatedAudioAsset =>
      'assets/audio/tts/numbers/${slugifyKey(englishWord)}.mp3';
}
