import '../repositary/gamification_repositary.dart';
import 'package:nutrition_game/models/pet_model.dart';
import '../utils/xp_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/firebase_keys.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GamificationService {
  final GamificationRepository _repo;

  GamificationService(this._repo);

  /// Fetch the main pet data from Firestore
  Future<PetModel?> getMainPet() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        print('User not authenticated');
        return null;
      }

      final db = FirebaseFirestore.instance;
      final doc = await db
          .collection(FB.users)
          .doc(uid)
          .collection(FB.pets)
          .doc(FB.mainPetId)
          .get();

      if (!doc.exists) {
        print('Main pet not found');
        return null;
      }

      return PetModel.fromFirestore(doc);
    } catch (e) {
      print('Error fetching main pet: $e');
      return null;
    }
  }

  Future<void> handleFeedingEvent(PetModel pet, Map<String, dynamic> foodData, {void Function(int oldLevel, int newLevel)? onLevelUp}) async {
    print("DEBUG: Gamification started for ${pet.id}");
    
    // 1. Store old level BEFORE XP calculation
    int oldLevel = pet.level;
    
    // 2. Calculate XP  
    final double calories = (foodData['calories'] ?? 0).toDouble();
    final Map<String, dynamic> petEffect = foodData['petEffect'] ?? {};
    
    double baseXp = calories * 0.1;
    if ((petEffect['health'] ?? 0) > 0) baseXp *= 1.5;
    
    final Map<String, dynamic> vits = Map<String, dynamic>.from(foodData['vitamins'] ?? {});
    if (vits.values.any((v) => v is num && v > 0)) baseXp *= 1.2;

    // 3. Calculate new level AFTER XP addition
    double newTotalXp = pet.xp + baseXp;
    int newLevel = XpEngine.calculateLevel(newTotalXp);
    
    print("DEBUG: Old Level: $oldLevel, New XP: $newTotalXp, New Level: $newLevel");

    // 4. Calculate New Streak
    int newStreak = calculateNewStreak(pet.lastFed.toDate(), pet.streaks);
    print("DEBUG: Old Streak: ${pet.streaks}, New Streak: $newStreak");

    // 5. Update via Repository
    await _repo.updatePetProgress(pet.id, baseXp, newStreak);
    
    // 6. If level increased and callback provided, pass the level change
    if (newLevel > oldLevel && onLevelUp != null) {
      onLevelUp(oldLevel, newLevel);
    }
  }

  int calculateNewStreak(DateTime? lastFed, int currentStreak) {
    if (lastFed == null) return 1; // First time ever feeding

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastFedDate = DateTime(lastFed.year, lastFed.month, lastFed.day);

    final difference = today.difference(lastFedDate).inDays;

    if (difference == 0) {
      return currentStreak <= 0 ? 1 : currentStreak; 
    } else if (difference == 1) {
      return currentStreak + 1;
    } else {
      return 1;
    }
  }
}