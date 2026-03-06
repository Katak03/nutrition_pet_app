import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pet_model.dart';

class StatDecayService {

  static PetModel applyStatDecay(PetModel pet) {
  final now = DateTime.now();
  final lastInteraction = pet.lastInteraction.toDate();

  final hoursPassed =
      now.difference(lastInteraction).inHours;

  if (hoursPassed < 1) return pet;

  const decayRate = 2;

  int newHunger =
      pet.hunger - (hoursPassed * decayRate);

  int newHappiness =
      pet.happiness - (hoursPassed * decayRate);

  int newHealth = pet.health;

  if (newHunger < 30) {
    newHealth -= hoursPassed;
  }

  final updatedInteraction =
      lastInteraction.add(Duration(hours: hoursPassed));

  return pet.copyWith(
    hunger: newHunger.clamp(0, 100),
    happiness: newHappiness.clamp(0, 100),
    health: newHealth.clamp(0, 100),
    lastInteraction:
        Timestamp.fromDate(updatedInteraction),
  );
}
}