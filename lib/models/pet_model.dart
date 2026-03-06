import 'package:cloud_firestore/cloud_firestore.dart';

class PetModel {
  final String id;
  final int happiness;
  final int hunger;
  final int health;
  final Timestamp lastFed;
  final Timestamp lastInteraction;
  final String assetId;
  final int streaks;
  final int level;
  final double xp;

  PetModel({
    required this.id,
    required this.happiness,
    required this.hunger,
    required this.health,
    required this.lastFed,
    required this.lastInteraction,
    required this.assetId,
    required this.streaks,
    required this.level,
    required this.xp,
  });

  factory PetModel.fromFirestore(DocumentSnapshot doc) {
    if (!doc.exists || doc.data() == null) {
      throw Exception('Pet document not found in Firebase!');
    }

    final data = doc.data() as Map<String, dynamic>;
    final stats = data['stats'] ?? {};
    final timestamps = data['timestamps'] ?? {};
    final gamification = data['gamification'] ?? {};

    return PetModel(
      id: doc.id,
      happiness: stats['happiness'] ?? 100,
      hunger: stats['hunger'] ?? 100,
      health: stats['health'] ?? 100,
      lastFed: timestamps['lastFed'] ?? Timestamp.now(),
      lastInteraction: timestamps['lastInteraction'] ?? Timestamp.now(),
      // Changed this to default to 'placeholder' instead of 'happy_pet'
      assetId: data['assetId'] ?? 'placeholder',
      streaks: gamification['streaks'] ?? 0,
      level: data['level'] ?? 1,
      xp: (data['xp'] ?? 0.0).toDouble(),
    );
  }

  PetModel copyWith({
    int? happiness,
    int? hunger,
    int? health,
    Timestamp? lastInteraction,
    String? assetId,
    int? streaks,
    int? level,
    double? xp,
  }) {
    return PetModel(
      id: id,
      happiness: happiness ?? this.happiness,
      hunger: hunger ?? this.hunger,
      health: health ?? this.health,
      lastFed: lastFed,
      lastInteraction: lastInteraction ?? this.lastInteraction,
      assetId: assetId ?? this.assetId,
      streaks: streaks ?? this.streaks,
      level: level ?? this.level,
      xp: xp ?? this.xp,
    );
  }
}