class UserModel {
  final String username;
  final String email;
  final NutritionGoals nutritionGoals;

  UserModel({
    required this.username,
    required this.email,
    required this.nutritionGoals,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data) {
    final goals = data['nutritionGoals'] ?? {};
    return UserModel(
      username: data['username'] ?? 'User',
      email: data['email'] ?? '',
      nutritionGoals: NutritionGoals(
        dailyCalories: (goals['dailyCalories'] ?? 2500).toDouble(),
        protein: (goals['protein'] ?? 50).toDouble(),
        carbs: (goals['carbs'] ?? 300).toDouble(),
        fats: (goals['fats'] ?? 70).toDouble(),
      ),
    );
  }
}

class NutritionGoals {
  final double dailyCalories;
  final double protein;
  final double carbs;
  final double fats;

  NutritionGoals({
    required this.dailyCalories,
    required this.protein,
    required this.carbs,
    required this.fats,
  });
}