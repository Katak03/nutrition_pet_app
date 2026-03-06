class NutritionCalculator {
  /// Calculates the daily nutrition goals based on user profile.
  /// Returns a Map with keys: dailyCalories, protein, carbs, fats (all integers).
  static Map<String, int> calculateGoals({
    required double weight, // in kg
    required double height, // in cm
    required int age,       // in years
    required String sex,    // 'Male' or 'Female'
    required String activityLevel, // 'low', 'moderate', 'high'
    required String goalType,      // 'lose', 'maintain', 'gain'
  }) {
    // 1. Calculate BMR (Mifflin–St Jeor Formula)
    double bmr;
    if (sex.toLowerCase() == 'male') {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }

    // 2. Calculate TDEE (Activity Multiplier)
    double tdeeMultiplier;
    switch (activityLevel.toLowerCase()) {
      case 'moderate':
        tdeeMultiplier = 1.55;
        break;
      case 'high':
        tdeeMultiplier = 1.725;
        break;
      case 'low':
      default:
        tdeeMultiplier = 1.375;
        break;
    }
    double tdee = bmr * tdeeMultiplier;

    // 3. Adjust Calories Based on Goal
    double targetCalories = tdee;
    double proteinMultiplier = 1.5; // Default for maintenance

    if (goalType.toLowerCase() == 'lose') {
      targetCalories -= 400;
      proteinMultiplier = 2.0;
    } else if (goalType.toLowerCase() == 'gain') {
      targetCalories += 400;
      proteinMultiplier = 2.2;
    }

    // Ensure calories don't drop to dangerous levels (e.g., minimum 1200)
    if (targetCalories < 1200) targetCalories = 1200;

    // 4. Calculate Macronutrients (in grams)
    double proteinGrams = weight * proteinMultiplier;
    double fatGrams = weight * 0.9;

    // Calories consumed by protein and fat
    double proteinCals = proteinGrams * 4;
    double fatCals = fatGrams * 9;

    // Remaining calories are for carbs
    double remainingCals = targetCalories - proteinCals - fatCals;
    
    // If the math results in negative carbs (extreme deficit on a heavy person), floor to 0
    double carbGrams = remainingCals > 0 ? (remainingCals / 4) : 0;

    // Return rounded integer values for the Firestore Schema
    return {
      'dailyCalories': targetCalories.round(),
      'protein': proteinGrams.round(),
      'carbs': carbGrams.round(),
      'fats': fatGrams.round(),
    };
  }
}