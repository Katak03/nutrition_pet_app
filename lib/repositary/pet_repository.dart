import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/pet_model.dart';
import '../models/food_model.dart';
import '../services/stat_decay_service.dart';

class PetRepository {
  final _db = FirebaseFirestore.instance;
  String get uid => FirebaseAuth.instance.currentUser!.uid;

  // Stream pet and apply decay on the fly for UI
  Stream<PetModel> streamPet(String petId) {
  return _db
      .collection('users')
      .doc(uid)
      .collection('pets')
      .doc(petId)
      .snapshots()
      .map((doc) => PetModel.fromFirestore(doc));
}

  // Force save decayed stats (called on screen load)
  Future<void> saveDecayedStats(PetModel pet) async {

  final updatedPet =
      StatDecayService.applyStatDecay(pet);

  if (updatedPet.hunger == pet.hunger &&
      updatedPet.happiness == pet.happiness &&
      updatedPet.health == pet.health) {
    return; // ✅ no update loop
  }

  await _db
      .collection('users')
      .doc(uid)
      .collection('pets')
      .doc(pet.id)
      .update({
    'stats.hunger': updatedPet.hunger,
    'stats.happiness': updatedPet.happiness,
    'stats.health': updatedPet.health,
    'timestamps.lastInteraction':
        updatedPet.lastInteraction,
  });
}
}

class FoodRepository {
  Stream<List<FoodModel>> streamFoods() {
    return FirebaseFirestore.instance.collection('foods').snapshots().map(
      (snap) => snap.docs.map((doc) => FoodModel.fromFirestore(doc)).toList()
    );
  }
}