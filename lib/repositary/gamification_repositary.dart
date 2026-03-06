import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutrition_game/utils/xp_engine.dart';

class GamificationRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String uid;

  GamificationRepository({required this.uid});

  // Stream for UI to consume via StreamBuilder
  Stream<Map<String, dynamic>> streamPetStats(String petId) {
    return _db.collection('users').doc(uid).collection('pets').doc(petId).snapshots().map((doc) => doc.data() ?? {});
  }

  // Inside gamification_repository.dart

Future<void> updatePetProgress(String petId, double xpToAdd, int newStreak) async {
  final petRef = _db.collection('users').doc(uid).collection('pets').doc(petId);

  return _db.runTransaction((transaction) async {
    final snapshot = await transaction.get(petRef);
    if (!snapshot.exists) return;

    final data = snapshot.data()!;
    
    // 1. Read the ORIGINAL root-level XP
    double currentXp = (data['xp'] ?? 0.0).toDouble(); 
    
    // 2. Calculate new totals
    double newXp = currentXp + xpToAdd;
    int newLevel = XpEngine.calculateLevel(newXp);

    // 3. Write to the exact original schema paths
    transaction.update(petRef, {
      'xp': newXp, // Updates the root XP field (UI will see this!)
      'level': newLevel, // Updates the root Level field
      'gamification.totalScore': newXp, // Keep this synced if leaderboards use it
      'gamification.streaks': newStreak, // Updates nested streak map
      
      // OPTIONAL CLEANUP: Remove the accidental duplicates we made earlier
      // You can delete these two lines once the DB is clean
      'gamification.level': FieldValue.delete(), 
    });
  });
}
}