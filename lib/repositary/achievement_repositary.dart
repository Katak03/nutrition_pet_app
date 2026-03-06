import 'package:cloud_firestore/cloud_firestore.dart';

class AchievementRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Fetch all master achievements once to avoid duplicate reads
  Future<List<Map<String, dynamic>>> fetchMasterAchievements() async {
    final snapshot = await _db.collection('achievements').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id; // Inject the document ID for easy reference
      return data;
    }).toList();
  }

  /// Fetch IDs of already unlocked achievements for the user
  Future<Set<String>> fetchUnlockedAchievementIds(String uid) async {
    final snapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('unlocked_achievements')
        .get();
    
    return snapshot.docs.map((doc) => doc.id).toSet();
  }

  /// Safely unlock an achievement
  Future<void> unlockAchievement(String uid, String achievementId) async {
    final ref = _db
        .collection('users')
        .doc(uid)
        .collection('unlocked_achievements')
        .doc(achievementId);

    // Use set with merge to avoid overwriting if somehow called twice
    await ref.set({
      'earnedAt': FieldValue.serverTimestamp(),
      'rewardClaimed': false,
    }, SetOptions(merge: true));
  }
}