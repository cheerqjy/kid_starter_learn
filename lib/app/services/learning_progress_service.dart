import 'package:shared_preferences/shared_preferences.dart';

class LearningSummary {
  final Set<String> openedModules;
  final Set<String> completedStages;
  final Set<String> watchedVideos;
  final int starsEarned;
  final int numbersPracticed;
  final int shapesPracticed;
  final int storiesPlayed;

  const LearningSummary({
    required this.openedModules,
    required this.completedStages,
    required this.watchedVideos,
    required this.starsEarned,
    required this.numbersPracticed,
    required this.shapesPracticed,
    required this.storiesPlayed,
  });

  int get routeCompletedCount {
    return [
      openedModules.contains('abc'),
      openedModules.contains('numbers'),
      openedModules.contains('colors'),
      openedModules.contains('animals'),
      openedModules.contains('shapes'),
      openedModules.contains('abc_sounds'),
      openedModules.contains('phonics'),
      openedModules.contains('prepositions'),
      openedModules.contains('stories'),
    ].where((value) => value).length;
  }

  double get routeProgress => routeCompletedCount / 9;
}

class LearningProgressService {
  static const _openedModulesKey = 'opened_modules';
  static const _completedStagesKey = 'completed_stages';
  static const _watchedVideosKey = 'watched_videos';
  static const _starsKey = 'stars_earned';
  static const _numbersKey = 'numbers_practiced';
  static const _shapesKey = 'shapes_practiced';
  static const _storiesKey = 'stories_played';

  static SharedPreferences? _prefs;

  static Future<void> ensureReady() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static SharedPreferences get _instance {
    final prefs = _prefs;
    if (prefs == null) {
      throw StateError('LearningProgressService.ensureReady() was not called.');
    }
    return prefs;
  }

  static Future<void> markModuleOpened(String moduleId) async {
    await ensureReady();
    final opened = _instance.getStringList(_openedModulesKey)?.toSet() ?? {};
    opened.add(moduleId);
    await _instance.setStringList(_openedModulesKey, opened.toList()..sort());
  }

  static Future<void> markStageCompleted(String stageId) async {
    await ensureReady();
    final stages = _instance.getStringList(_completedStagesKey)?.toSet() ?? {};
    stages.add(stageId);
    await _instance.setStringList(_completedStagesKey, stages.toList()..sort());
  }

  static Future<void> markVideoWatched(String letter) async {
    await ensureReady();
    final videos = _instance.getStringList(_watchedVideosKey)?.toSet() ?? {};
    videos.add(letter);
    await _instance.setStringList(_watchedVideosKey, videos.toList()..sort());
  }

  static Future<void> addStars(int stars) async {
    await ensureReady();
    final next = _instance.getInt(_starsKey) ?? 0;
    await _instance.setInt(_starsKey, next + stars);
  }

  static Future<void> incrementNumbersPracticed() async {
    await ensureReady();
    final next = _instance.getInt(_numbersKey) ?? 0;
    await _instance.setInt(_numbersKey, next + 1);
  }

  static Future<void> incrementShapesPracticed() async {
    await ensureReady();
    final next = _instance.getInt(_shapesKey) ?? 0;
    await _instance.setInt(_shapesKey, next + 1);
  }

  static Future<void> incrementStoriesPlayed() async {
    await ensureReady();
    final next = _instance.getInt(_storiesKey) ?? 0;
    await _instance.setInt(_storiesKey, next + 1);
  }

  static Future<LearningSummary> loadSummary() async {
    await ensureReady();
    return LearningSummary(
      openedModules: _instance.getStringList(_openedModulesKey)?.toSet() ?? {},
      completedStages:
          _instance.getStringList(_completedStagesKey)?.toSet() ?? {},
      watchedVideos: _instance.getStringList(_watchedVideosKey)?.toSet() ?? {},
      starsEarned: _instance.getInt(_starsKey) ?? 0,
      numbersPracticed: _instance.getInt(_numbersKey) ?? 0,
      shapesPracticed: _instance.getInt(_shapesKey) ?? 0,
      storiesPlayed: _instance.getInt(_storiesKey) ?? 0,
    );
  }
}
