import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/firebase_keys.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // --- LOGIN ---
  Future<UserCredential> signIn({required String email, required String password}) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // --- REGISTER ---
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String username,
    required int age,
    required String sex,
    required double height,
    required double weight,
    required String activityLevel,
    required String goalType,
    required int dailyCalories,
    required int protein,
    required int carbs,
    required int fats,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        // We call our new unified initialization method here
        await _initializeUserAndPet(
          uid: result.user!.uid,
          email: email,
          username: username,
          age: age,
          sex: sex,
          height: height,
          weight: weight,
          activityLevel: activityLevel,
          goalType: goalType,
          dailyCalories: dailyCalories,
          protein: protein,
          carbs: carbs,
          fats: fats,
        );
      }
      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // --- ATOMIC INITIALIZATION (Profile + Pet Sub-collection) ---
  Future<void> _initializeUserAndPet({
    required String uid,
    required String email,
    required String username,
    required int age,
    required String sex,
    required double height,
    required double weight,
    required String activityLevel,
    required String goalType,
    required int dailyCalories,
    required int protein,
    required int carbs,
    required int fats,
  }) async {
    WriteBatch batch = _firestore.batch();

    // 1. References
    DocumentReference userRef = _firestore.collection(FB.users).doc(uid);
    // We use mainPetId (ensure this is 'main_pet' in your keys file)
    DocumentReference petRef = userRef.collection(FB.pets).doc(FB.mainPetId);

    // 2. Prepare User Profile Data
    batch.set(userRef, {
      FB.username: username,
      FB.email: email,
      FB.createdAt: FieldValue.serverTimestamp(),
      FB.profile: {
        FB.age: age,
        FB.sex: sex,
        FB.height: height,
        FB.weight: weight,
        FB.activityLevel: activityLevel,
        FB.goalType: goalType,
      },
      FB.nutritionGoals: {
        FB.dailyCalories: dailyCalories,
        FB.protein: protein,
        FB.carbs: carbs,
        FB.fats: fats,
      },
    });

    // 3. Prepare Pet Data (Includes all fields from your screenshots)
    batch.set(petRef, {
      FB.name: username, // Uses the username as the pet's default name
      FB.assetId: 'placeholder', 
      FB.level: 1,
      'xp': 0,
      FB.stats: {
        FB.happiness: 100,
        FB.hunger: 100,
        FB.health: 100,
      },
      // Gamification Mapping as requested
      'gamification': {
        'streaks': 0,
        'totalScore': 0,
      },
      FB.timestamps: {
        FB.lastFed: FieldValue.serverTimestamp(),
        FB.lastInteraction: FieldValue.serverTimestamp(),
      },
    });

    await batch.commit();
  }

  Future<void> signOut() async => await _auth.signOut();

  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found': return 'No user found for that email.';
      case 'wrong-password': return 'Wrong password provided.';
      case 'email-already-in-use': return 'The account already exists.';
      default: return e.message ?? 'An error occurred';
    }
  }
}