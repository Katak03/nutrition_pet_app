import '../models/daily_log_model.dart';

class PetAssetResolver {
  static String resolveAsset({
    required int health,
    required int hunger,
    required int happiness,
    required DailyLogModel log,
    required List<DailyLogModel> recentLogs,
  }) {
    if (health < 30) return 'sick_pet';
    if (hunger < 30) return 'hungry_pet';
    if (happiness < 30) return 'sad_pet';

    if (health > 30) {
      if (recentLogs.length >= 2 &&
          recentLogs[recentLogs.length - 2].vitamins['a']! < 900 &&
          log.vitamins['a']! < 900) {
        return 'eye_sick_pet';
      }
      if (recentLogs.length >= 2 &&
          recentLogs[recentLogs.length - 2].vitamins['b12']! < 2.4 &&
          log.vitamins['b12']! < 2.4) {
        return 'tired_pet';
      }
      if (recentLogs.length >= 2 &&
          recentLogs[recentLogs.length - 2].vitamins['c']! < 90 &&
          log.vitamins['c']! < 90) {
        return 'bandage cat';
      }
      if (recentLogs.length >= 2 &&
          recentLogs[recentLogs.length - 2].vitamins['d']! < 15 &&
          log.vitamins['d']! < 15) {
        return 'weak_pet';
      }
    }

    return 'happy_pet';
  }
}