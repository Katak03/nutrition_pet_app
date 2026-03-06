// daily_log_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class DailyLogModel {
  final double totalCalories;
  final double water;
  final Map<String, double> macros;
  final Map<String, double> vitamins;
  final DateTime date;

  DailyLogModel({
    required this.totalCalories,
    required this.water,
    required this.macros,
    required this.vitamins,
    required this.date,
  });

  factory DailyLogModel.fromFirestore(DocumentSnapshot doc) {
  final data = doc.data() as Map<String, dynamic>? ?? {};
  
  // 1. Get the list of food entries
  final List<dynamic> foodEntries = data['foodEntries'] ?? [];
  final Map<String, dynamic> m = data['macros'] is Map ? data['macros'] : {};
  final Map<String, dynamic> v = data['vitamins'] is Map ? data['vitamins'] : {};
  
  // 2. Initialize our counters
  double calculatedCalories = 0;
  double p = 0;
  double c = 0;
  double f = 0;
  double vitA = 0, vitB12 = 0, vitC = 0, vitD = 0;

  // 3. Loop through each entry and sum the values
  for (var entry in foodEntries) {
    final Map<String, dynamic> entryData = entry as Map<String, dynamic>;
    
    // Sum Calories
    calculatedCalories += (entryData['calories'] ?? 0).toDouble();
    
    // Sum Macros
    final m = entryData['macros'] ?? {};
    p += (m['protein'] ?? 0).toDouble();
    c += (m['carbs'] ?? 0).toDouble();
    f += (m['fats'] ?? 0).toDouble();
    
    // Sum Vitamins (if present in the food entry)
    final v = entryData['vitamins'] ?? {};
    vitA += (v['vitamin_a'] ?? 0).toDouble();
    vitB12 += (v['vitamin_b12'] ?? 0).toDouble();
    vitC += (v['vitamin_c'] ?? 0).toDouble();
    vitD += (v['vitamin_d'] ?? 0).toDouble();
  }

  return DailyLogModel(
    date: DateTime.tryParse(doc.id) ?? DateTime.now(),
    // Use our calculated totals
    totalCalories: calculatedCalories,
    // Fetch top-level fields like the water you added manually
    water: (data['water'] ?? 0).toDouble(),
    macros: {
      'protein': p,
      'carbs': c,
      'fats': f,
    },
    vitamins: {'a': vitA, 'b12': vitB12, 'c': vitC, 'd': vitD},
  );
}

  factory DailyLogModel.empty(DateTime date) => DailyLogModel(
    date: date,
    totalCalories: 0,
    water: 0,
    macros: {'protein': 0, 'carbs': 0, 'fats': 0},
    vitamins: {'a': 0, 'b12': 0, 'c': 0, 'd': 0},
  );
}