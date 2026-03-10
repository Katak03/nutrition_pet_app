import 'package:nutrition_game/repositary/achievement_repositary.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AchievementService {
  final AchievementRepository _repo;
  
  // In-memory caches to prevent duplicate Firestore reads
  List<Map<String, dynamic>> _masterAchievements = [];
  
  // CHANGED: Now stores Achievement ID -> rewardClaimed status
  Map<String, bool> _unlockedAchievements = {}; 
  bool _isInitialized = false;

  AchievementService(this._repo);

  /// Called by the Engine on startup
  Future<void> initialize(String uid) async {
    _masterAchievements = await _repo.fetchMasterAchievements();
    _unlockedAchievements = await _repo.fetchUnlockedAchievements(uid);
    _isInitialized = true;
    print("DEBUG: AchievementService initialized. Loaded ${_masterAchievements.length} masters, ${_unlockedAchievements.length} unlocked.");
  }

  /// Get ONLY achievements where rewardClaimed == true
  Future<List<Map<String, dynamic>>> getAchievements() async {
    try {
      if (!_isInitialized) {
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) {
          await initialize(uid);
        }
      }

      List<Map<String, dynamic>> claimedAchievements = [];

      for (var achievement in _masterAchievements) {
        String id = achievement['id'];
        
        // Filter logic: Check if it's unlocked AND rewardClaimed is true
        if (_unlockedAchievements.containsKey(id) && _unlockedAchievements[id] == true) {
          claimedAchievements.add({
            ...achievement,
            'isUnlocked': true,
          });
        }
      }

      return claimedAchievements;
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
      
      // Skip if already unlocked (we check this regardless of claim status so the engine doesn't fire duplicates)
      if (_unlockedAchievements.containsKey(id)) continue;

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
        
        // 1. Add to local cache as unlocked, but rewardClaimed is FALSE
        _unlockedAchievements[id] = false; 
        
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
    _unlockedAchievements.clear();
    _isInitialized = false;
  }
}