import '../models/daily_log_model.dart';

class PetAssetResolver {
  static String resolveAsset({
    required int health,
    required int hunger,
    required int happiness,
    required DailyLogModel log,
    required List<DailyLogModel> recentLogs,
  }) {
    if (health < 30) return 'sick';
    if (hunger < 30) return 'hungry';
    if (happiness < 30) return 'sad';

    if (health > 30) {
      if (recentLogs.length >= 2 &&
          recentLogs[recentLogs.length - 2].vitamins['a']! < 900 &&
          log.vitamins['a']! < 900) {
        return 'def_a';
      }
      if (recentLogs.length >= 2 &&
          recentLogs[recentLogs.length - 2].vitamins['b1']! < 1.2 &&
          log.vitamins['b1']! < 1.2) {
        return 'def_b1';
      }
      if (recentLogs.length >= 2 &&
          recentLogs[recentLogs.length - 2].vitamins['c']! < 90 &&
          log.vitamins['c']! < 90) {
        return 'def_c';
      }
      if (recentLogs.length >= 2 &&
          recentLogs[recentLogs.length - 2].vitamins['b2']! < 1.3 &&
          log.vitamins['b2']! < 1.3) {
        return 'def_b2';
      }
    }

    return 'happy';
  }
}