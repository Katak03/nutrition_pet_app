import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutrition_game/services/achievement_service.dart';

class AchievementEngine {
  final AchievementService _service;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  StreamSubscription? _petSubscription;
  StreamSubscription? _logSubscription;

  // Store latest values to combine them
  Map<String, dynamic> _latestStats = {
    'level': 0,
    'streak': 0,
    'totalScore': 0,
    'nutritionGoal': 0, // Could represent total calories or a boolean 1/0
  };

  AchievementEngine(this._service);

  /// Start listening to Firestore changes automatically
  Future<void> startEngine(String uid, String petId) async {
    print("DEBUG: Starting Achievement Engine...");
    
    // 1. Initialize Service (loads caches)
    await _service.initialize(uid);

    // 2. Listen to Pet Progress (level, streaks, totalScore)
    _petSubscription = _db
        .collection('users')
        .doc(uid)
        .collection('pets')
        .doc(petId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data()!;
        final gamification = data['gamification'] ?? {};
        
        _latestStats['level'] = data['level'] ?? 0;
        _latestStats['streak'] = gamification['streaks'] ?? 0;
        _latestStats['totalScore'] = data['xp'] ?? gamification['totalScore'] ?? 0;

        _triggerEvaluation(uid);
      }
    });

    // 3. Listen to Today's Daily Log (nutrition goals)
    final dateStr = DateTime.now().toIso8601String().split('T').first;
    _logSubscription = _db
        .collection('users')
        .doc(uid)
        .collection('daily_logs')
        .doc(dateStr)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data()!;
        
        // Example logic: nutritionGoal criteria looks at total calories mapped to a target
        _latestStats['nutritionGoal'] = data['totalCalories'] ?? 0;
        
        _triggerEvaluation(uid);
      }
    });
  }

  /// Fire the evaluation in the service layer using the combined reactive state
  void _triggerEvaluation(String uid) {
    _service.evaluateAchievements(uid, _latestStats);
  }

  /// Clean up memory & listeners when the user logs out
  void disposeEngine() {
    print("DEBUG: Disposing Achievement Engine...");
    _petSubscription?.cancel();
    _logSubscription?.cancel();
    _service.clear();
  }
}