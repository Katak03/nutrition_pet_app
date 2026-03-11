import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/daily_log_model.dart';

/// Daily nutrition recommendations (standard guidelines)
class NutritionRecommendations {
  static const double vitaminA = 700; // mcg
  static const double vitaminB12 = 2.4; // mcg
  static const double vitaminC = 75; // mg
  static const double vitaminD = 600; // IU
  static const double water = 2000; // ml
  static const double protein = 50; // g
}

/// Message templates for each nutrient
class NutrientMessages {
  static final Map<String, String> messages = {
    'vitamin_a': "I need more Vitamin A to help my vision!",
    'vitamin_b12': "I'm low on energy, I need Vitamin B12!",
    'vitamin_c': "I'm feeling weak, can I have more Vitamin C?",
    'vitamin_d': "I need Vitamin D to keep my bones strong!",
    'water': "I'm thirsty! Can I have some water?",
    'protein': "I need more protein to grow stronger!",
  };
}

/// Detects which nutrients are low across the last 2 daily logs
class NutritionAlertService {
  final _db = FirebaseFirestore.instance;
  String get uid => FirebaseAuth.instance.currentUser!.uid;

  /// Fetches the last 2 daily logs
  Future<List<DailyLogModel>> getLastTwoDailyLogs() async {
    try {
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));

      final todayDoc = await _db
          .collection('users')
          .doc(uid)
          .collection('daily_logs')
          .doc(_formatDate(today))
          .get();

      final yesterdayDoc = await _db
          .collection('users')
          .doc(uid)
          .collection('daily_logs')
          .doc(_formatDate(yesterday))
          .get();

      final logs = <DailyLogModel>[];
      if (todayDoc.exists) {
        logs.add(DailyLogModel.fromFirestore(todayDoc));
      }
      if (yesterdayDoc.exists) {
        logs.add(DailyLogModel.fromFirestore(yesterdayDoc));
      }

      return logs;
    } catch (e) {
      print('Error fetching daily logs: $e');
      return [];
    }
  }

  /// Detects nutrients that are below recommended values for BOTH days
  Future<List<String>> detectLowNutrients() async {
    final logs = await getLastTwoDailyLogs();

    if (logs.length < 2) {
      return []; // Not enough data (need both days)
    }

    final lowNutrients = <String>[];

    // Check Vitamin A
    if (logs.every((log) => (log.vitamins['a'] ?? 0) < NutritionRecommendations.vitaminA)) {
      lowNutrients.add('vitamin_a');
    }

    // Check Vitamin B12
    if (logs.every((log) => (log.vitamins['b12'] ?? 0) < NutritionRecommendations.vitaminB12)) {
      lowNutrients.add('vitamin_b12');
    }

    // Check Vitamin C
    if (logs.every((log) => (log.vitamins['c'] ?? 0) < NutritionRecommendations.vitaminC)) {
      lowNutrients.add('vitamin_c');
    }

    // Check Vitamin D
    if (logs.every((log) => (log.vitamins['d'] ?? 0) < NutritionRecommendations.vitaminD)) {
      lowNutrients.add('vitamin_d');
    }

    // Check Water
    if (logs.every((log) => log.water < NutritionRecommendations.water)) {
      lowNutrients.add('water');
    }

    // Check Protein
    if (logs.every((log) => (log.macros['protein'] ?? 0) < NutritionRecommendations.protein)) {
      lowNutrients.add('protein');
    }

    return lowNutrients;
  }

  /// Gets a random message from low nutrients
  Future<String?> getRandomNutrientMessage() async {
    final lowNutrients = await detectLowNutrients();
    if (lowNutrients.isEmpty) return null;

    final random = (lowNutrients..shuffle()).first;
    return NutrientMessages.messages[random];
  }

  /// Helper: Format date as YYYY-MM-DD
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
