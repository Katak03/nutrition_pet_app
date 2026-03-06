class AntiCheatGuard {
  static const int maxDailyXp = 5000;
  static const int hungerThreshold = 95; // Pet is "too full" to gain XP

  bool canGainFeedingXp({
    required double currentHunger,
    required double dailyXpEarned,
    required DateTime lastInteraction,
  }) {
    // 1. Prevent XP abuse if pet is already full
    if (currentHunger >= hungerThreshold) return false;

    // 2. Daily XP Cap
    if (dailyXpEarned >= maxDailyXp) return false;

    // 3. Simple cooldown (e.g., 5 seconds between feed events)
    if (DateTime.now().difference(lastInteraction).inSeconds < 5) return false;

    return true;
  }
}