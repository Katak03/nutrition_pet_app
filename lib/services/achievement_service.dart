import 'package:nutrition_game/repositary/achievement_repositary.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AchievementService {
  final AchievementRepository _repo;
  
  // In-memory caches to prevent duplicate Firestore reads
  List<Map<String, dynamic>> _masterAchievements = [];
  Set<String> _unlockedIds = {};
  bool _isInitialized = false;

  AchievementService(this._repo);

  /// Called by the Engine on startup
  Future<void> initialize(String uid) async {
    _masterAchievements = await _repo.fetchMasterAchievements();
    _unlockedIds = await _repo.fetchUnlockedAchievementIds(uid);
    _isInitialized = true;
    print("DEBUG: AchievementService initialized. Loaded ${_masterAchievements.length} masters, ${_unlockedIds.length} unlocked.");
  }

  /// Get all achievements with their unlock status
  Future<List<Map<String, dynamic>>> getAchievements() async {
    try {
      // Fetch fresh data if not initialized
      if (!_isInitialized) {
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) {
          await initialize(uid);
        }
      }

      // Return achievements with isUnlocked flag
      return _masterAchievements.map((achievement) {
        return {
          ...achievement,
          'isUnlocked': _unlockedIds.contains(achievement['id']),
        };
      }).toList();
    } catch (e) {
      print('Error fetching achievements: $e');
      return [];
    }
  }

  /// Evaluates current user stats against locked achievements
  Future<void> evaluateAchievements(String uid, Map<String, dynamic> currentStats) async {
    if (!_isInitialized) return;

    for (var achievement in _masterAchievements) {
      String id = achievement['id'];
      
      // Skip if already unlocked
      if (_unlockedIds.contains(id)) continue;

      Map<String, dynamic> criteria = achievement['criteria'] ?? {};
      String type = criteria['type']; // e.g., 'level', 'streak'
      String operator = criteria['operator']; // e.g., '>=', '=='
      num targetValue = criteria['value'] ?? 0;

      // Extract the relevant stat from the engine's payload
      num currentStatValue = currentStats[type] ?? 0;

      // Evaluate logic
      bool isUnlocked = _evaluateCondition(currentStatValue, operator, targetValue);

      if (isUnlocked) {
        print("🎉 ACHIEVEMENT UNLOCKED: ${achievement['title']}!");
        
        // 1. Add to local cache immediately to prevent duplicate triggers
        _unlockedIds.add(id); 
        
        // 2. Persist to Firestore
        await _repo.unlockAchievement(uid, id);
      }
    }
  }

  /// Dynamic operator evaluation
  bool _evaluateCondition(num currentValue, String operator, num targetValue) {
    switch (operator) {
      case '>=': return currentValue >= targetValue;
      case '>':  return currentValue > targetValue;
      case '==': return currentValue == targetValue;
      case '<=': return currentValue <= targetValue;
      default:
        print("WARNING: Unknown operator $operator");
        return false;
    }
  }
  
  /// Clear cache on logout
  void clear() {
    _masterAchievements.clear();
    _unlockedIds.clear();
    _isInitialized = false;
  }
}