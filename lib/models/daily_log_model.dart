// daily_log_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class DailyLogModel {
  final double totalCalories;
  final double water;
  final double sugar;
  final Map<String, double> macros;
  final Map<String, double> vitamins;
  final DateTime date;

  DailyLogModel({
    required this.totalCalories,
    required this.water,
    required this.sugar,
    required this.macros,
    required this.vitamins,
    required this.date,
  });

  factory DailyLogModel.fromFirestore(DocumentSnapshot doc) {
  final data = doc.data() as Map<String, dynamic>? ?? {};
  
  // 1. Get the list of food entries
  final List<dynamic> foodEntries = data['foodEntries'] ?? [];
  
  // 2. Initialize our counters
  double calculatedCalories = 0;
  double p = 0;
  double c = 0;
  double f = 0;
  double vitA = 0, vitB1 = 0, vitC = 0, vitB2 = 0;
  double totalSugar = 0;

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
    // Read from new Firestore structure (a, b1, c, b2)
    final v = entryData['vitamins'] ?? {};
    vitA += (v['a'] ?? 0).toDouble();
    vitB1 += (v['b1'] ?? 0).toDouble();
    vitC += (v['c'] ?? 0).toDouble();
    vitB2 += (v['b2'] ?? 0).toDouble();
    
    // Sum Sugar
    totalSugar += (entryData['sugar'] ?? 0).toDouble();
  }

  return DailyLogModel(
    date: DateTime.tryParse(doc.id) ?? DateTime.now(),
    // Use our calculated totals
    totalCalories: calculatedCalories,
    // Fetch top-level fields like the water you added manually
    water: (data['water'] ?? 0).toDouble(),
    sugar: totalSugar,
    macros: {
      'protein': p,
      'carbs': c,
      'fats': f,
    },
    vitamins: {'a': vitA, 'b1': vitB1, 'c': vitC, 'b2': vitB2},
  );
}

  factory DailyLogModel.empty(DateTime date) => DailyLogModel(
    date: date,
    totalCalories: 0,
    water: 0,
    sugar: 0,
    macros: {'protein': 0, 'carbs': 0, 'fats': 0},
    vitamins: {'a': 0, 'b1': 0, 'c': 0, 'b2': 0},
  );
}