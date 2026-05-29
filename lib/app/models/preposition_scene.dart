import '../utils/audio_keys.dart';

enum PrepositionSceneType {
  inBox,
  onBox,
  besideBox,
  nearBox,
  aboveBox,
  belowBox,
  overBox,
  underBox,
  inFrontOfBox,
  behindBox,
  betweenBoxes,
  amongTrees,
  aroundBox,
  fromBox,
  intoBox,
  outOfBox,
  ontoBox,
  offBox,
  upHill,
  downHill,
  acrossRiver,
  throughTunnel,
}

class PrepositionScene {
  final String title;
  final String chineseTitle;
  final String exampleSentence;
  final String chinesePrompt;
  final String playHint;
  final PrepositionSceneType type;

  const PrepositionScene({
    required this.title,
    required this.chineseTitle,
    required this.exampleSentence,
    required this.chinesePrompt,
    required this.playHint,
    required this.type,
  });

  String get _audioKey => slugifyKey(title);

  String get wordAudioAsset =>
      'assets/audio/tts/prepositions/word/$_audioKey.mp3';

  String get phraseAudioAsset =>
      'assets/audio/tts/prepositions/phrase/$_audioKey.mp3';

  String get promptAudioAsset =>
      'assets/audio/tts/prepositions/prompt/$_audioKey.mp3';
}
