import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/pet_model.dart';
import '../models/food_model.dart';
import 'gamification_service.dart'; 

class FeedPetService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GamificationService _gamificationService;

  FeedPetService(this._gamificationService);

  Future<void> feedPet(PetModel pet, FoodModel food, {void Function(int oldLevel, int newLevel)? onLevelUp}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return; 

    final uid = user.uid;
    final dateStr = DateTime.now().toIso8601String().split('T').first; 
    
    final petRef = _db.collection('users').doc(uid).collection('pets').doc(pet.id);
    final logRef = _db.collection('users').doc(uid).collection('daily_logs').doc(dateStr);

    final batch = _db.batch();

    int newHappiness = (pet.happiness + (food.petEffect['happiness'] ?? 0)).clamp(0, 100).toInt();
    int newHunger = (pet.hunger + (food.petEffect['hunger'] ?? 0)).clamp(0, 100).toInt();
    int newHealth = (pet.health + (food.petEffect['health'] ?? 0)).clamp(0, 100).toInt();

    // 1. Update Pet Stats
    batch.update(petRef, {
      'stats.happiness': newHappiness,
      'stats.hunger': newHunger,
      'stats.health': newHealth,
      'timestamps.lastFed': FieldValue.serverTimestamp(),
      'timestamps.lastInteraction': FieldValue.serverTimestamp(),
    });

    // 2. Append to Daily Log
    final foodEntry = {
      'foodID': food.id,
      'name': food.name,
      'calories': food.calories,
      'macros': food.macros,
      'vitamins': food.vitamins,
      'petEffect': food.petEffect, 
      'timestamp': Timestamp.now()
    };

    batch.set(logRef, {
      'foodEntries': FieldValue.arrayUnion([foodEntry]),
      'totalCalories': FieldValue.increment(food.calories),
      'macros': {
        'protein': FieldValue.increment(food.macros['protein'] ?? 0),
        'carbs': FieldValue.increment(food.macros['carbs'] ?? 0),
        'fats': FieldValue.increment(food.macros['fats'] ?? 0),
      },
      'vitamins': { 
        'a': FieldValue.increment(food.vitA),
        'b12': FieldValue.increment(food.vitB12),
        'c': FieldValue.increment(food.vitC),
        'd': FieldValue.increment(food.vitD),
      },
    }, SetOptions(merge: true));

    // 3. Commit the feeding logs FIRST
    await batch.commit();

    // 4. NOW TRIGGER GAMIFICATION XP!
    final gamificationFoodData = {
      'calories': food.calories,
      'petEffect': food.petEffect,
      'vitamins': {
        'vitamin_a': food.vitA, 
        'vitamin_b12': food.vitB12, 
        'vitamin_c': food.vitC, 
        'vitamin_d': food.vitD
      }
    };
    
    await _gamificationService.handleFeedingEvent(pet, gamificationFoodData, onLevelUp: onLevelUp);
  }
}