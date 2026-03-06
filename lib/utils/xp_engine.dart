import 'dart:math';

class XpEngine {
  // Requirement formula: XP = 120 * level^1.6
  static double getRequiredXp(int level) {
    return (120 * pow(level, 1.6)).toDouble();
  }

  static int calculateLevel(double totalXp) {
    int level = 1;
    while (totalXp >= getRequiredXp(level)) {
      level++;
    }
    return level;
  }

  static double getProgressToNextLevel(double currentXp, int currentLevel) {
    double startXp = currentLevel == 1 ? 0 : getRequiredXp(currentLevel - 1);
    double endXp = getRequiredXp(currentLevel);
    return ((currentXp - startXp) / (endXp - startXp)).clamp(0.0, 1.0);
  }
}