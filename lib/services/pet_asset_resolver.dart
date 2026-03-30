import '../models/daily_log_model.dart';

class PetAssetResolver {
  static String resolveAsset({
    required int health,
    required int hunger,
    required int happiness,
    required DailyLogModel log,
    required List<DailyLogModel> recentLogs,
  }) {
    // Priority 1: Health
    if (health < 30) return 'sick';

    // Priority 2: Hunger
    if (hunger < 30) return 'hungry';

    // Priority 3: Happiness
    if (happiness < 30) return 'sad';

    // Priority 4: Vitamin deficiencies (only if we have a completed 7-day week)
    if (recentLogs.length >= 7) {
      // Get the last 7 logs (completed week)
      final completedWeek = recentLogs.sublist(recentLogs.length - 7);

      // Check each vitamin for weekly deficiency
      if (_wasVitaminDeficientAllWeek(completedWeek, 'a', 900)) return 'def_a';
      if (_wasVitaminDeficientAllWeek(completedWeek, 'b1', 1.2)) return 'def_b1';
      if (_wasVitaminDeficientAllWeek(completedWeek, 'c', 90)) return 'def_c';
      if (_wasVitaminDeficientAllWeek(completedWeek, 'b2', 1.3)) return 'def_b2';
    }

    // Priority 5: Default happy state
    return 'happy';
  }

  /// Returns true if a vitamin was below its threshold for all 7 days in the week.
  /// This means the vitamin was never fulfilled even once during that completed week.
  static bool _wasVitaminDeficientAllWeek(
    List<DailyLogModel> weekLogs,
    String vitaminKey,
    num threshold,
  ) {
    if (weekLogs.length != 7) return false;
    return weekLogs.every((log) => log.vitamins[vitaminKey]! < threshold);
  }
}