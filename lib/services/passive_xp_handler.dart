import '../repositary/gamification_repositary.dart';

class PassiveXpHandler {
  final GamificationRepository _repo;

  PassiveXpHandler(this._repo);

  Future<void> rewardMaintenance(String petId, Map<String, dynamic> currentStats) async {
    double happiness = (currentStats['happiness'] ?? 0).toDouble();
    double health = (currentStats['health'] ?? 0).toDouble();

    // Reward users if stats are above 80%
    if (happiness > 80 && health > 80) {
      // Notice we do NOT pass a newStreak here, because passive XP 
      // shouldn't affect feeding streaks.
      await _repo.updatePetProgress(petId, 50.0, 0); 
    }
  }
}