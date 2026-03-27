import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../models/daily_log_model.dart';

class UserProfileService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String uid;

  UserProfileService({required this.uid});

  Stream<UserModel> streamUser() {
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      // Pass doc.data() as a Map to your factory
      return UserModel.fromFirestore(doc.data() ?? {});
    });
  }

  Stream<DailyLogModel> streamTodayLog() {
  // Use a reliable way to get exactly YYYY-MM-DD
  final now = DateTime.now();
  final String today = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  
  print("DEBUG: Fetching log for User: $uid on Date: $today");

  return _db
      .collection('users')
      .doc(uid)
      .collection('daily_logs')
      .doc(today) // This must match "2026-03-03"
      .snapshots()
      .map((doc) {
        if (doc.exists) {
          return DailyLogModel.fromFirestore(doc);
        } else {
          // If the document doesn't exist for today yet, return an empty log
          return DailyLogModel.empty(now);
        }
      });
}
Future<List<double>> getCurrentWeekCalories(String uid) async {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final now = DateTime.now();

  // 1. Find the Monday of the current week
  // In Dart, Monday = 1, Sunday = 7. 
  // subtract (now.weekday - 1) days to get back to Monday.
  final DateTime monday = now.subtract(Duration(days: now.weekday - 1));

  // 2. Build the 7 fixed weekday IDs (YYYY-MM-DD) for Mon-Sun
  final List<String> currentWeekIds = List.generate(7, (i) {
    final date = monday.add(Duration(days: i));
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  });

  try {
    // 3. Fetch logs for this week specifically
    final snapshot = await db
        .collection('users')
        .doc(uid)
        .collection('daily_logs')
        .where(FieldPath.documentId, whereIn: currentWeekIds)
        .get();

    // 4. Map into a Lookup Map
    final Map<String, double> weekData = {};
    for (var doc in snapshot.docs) {
      weekData[doc.id] = (doc.data()['totalCalories'] ?? 0.0).toDouble();
    }

    // 5. Return List<double> ordered Mon -> Sun
    // Index 0 = Mon, Index 2 = Wed (Today), Index 6 = Sun
    return currentWeekIds.map((id) => weekData[id] ?? 0.0).toList();
    
  } catch (e) {
    // 7. Safety fallback: NEVER return []
    return [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
  }
}


  Stream<List<DailyLogModel>> streamWeeklyLogs() {
    return _db
        .collection('users')
        .doc(uid)
        .collection('daily_logs')
        .orderBy(FieldPath.documentId, descending: true)
        .limit(7)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DailyLogModel.fromFirestore(doc))
            .toList());
  }

  // Initialize today's daily log with proper structure (if not exists)
  Future<void> initializeTodayLog() async {
    final now = DateTime.now();
    final String today = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    
    final logRef = _db
        .collection('users')
        .doc(uid)
        .collection('daily_logs')
        .doc(today);
    
    // Only create if it doesn't exist
    final doc = await logRef.get();
    if (!doc.exists) {
      await logRef.set({
        'totalCalories': 0,
        'water': 0,
        'sugar': 0,
        'macros': {
          'protein': 0,
          'carbs': 0,
          'fats': 0,
        },
        'vitamins': {
          'a': 0,
          'b1': 0,
          'c': 0,
          'b2': 0,
        },
        'foodEntries': [],
      });
    }
  }
}