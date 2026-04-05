/// Represents a serializable snapshot of the pet's state for iOS widget display.
class PetSnapshot {
  final String petId;
  final String name;
  final String assetId;
  final int level;
  final int xp;
  final PetStats stats;
  final int lastUpdate; // Unix timestamp in milliseconds
  final int lastFedAt; // Unix timestamp in milliseconds

  PetSnapshot({
    required this.petId,
    required this.name,
    required this.assetId,
    required this.level,
    required this.xp,
    required this.stats,
    required this.lastUpdate,
    required this.lastFedAt,
  });

  /// Convert to JSON for storage in UserDefaults
  Map<String, dynamic> toJson() {
    return {
      'petId': petId,
      'name': name,
      'assetId': assetId,
      'level': level,
      'xp': xp,
      'stats': {
        'hunger': stats.hunger,
        'happiness': stats.happiness,
        'health': stats.health,
      },
      'lastUpdate': lastUpdate,
      'lastFedAt': lastFedAt,
    };
  }

  /// Create from JSON (from UserDefaults)
  factory PetSnapshot.fromJson(Map<String, dynamic> json) {
    final statsData = json['stats'] as Map<String, dynamic>? ?? {};
    
    return PetSnapshot(
      petId: json['petId'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
      assetId: json['assetId'] as String? ?? 'pet_happy',
      level: json['level'] as int? ?? 1,
      xp: json['xp'] as int? ?? 0,
      stats: PetStats(
        hunger: (statsData['hunger'] as int?) ?? 100,
        happiness: (statsData['happiness'] as int?) ?? 100,
        health: (statsData['health'] as int?) ?? 100,
      ),
      lastUpdate: json['lastUpdate'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      lastFedAt: json['lastFedAt'] as int? ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  String toString() {
    return 'PetSnapshot(id: $petId, name: $name, level: $level, stats: ${stats.toString()})';
  }
}

/// Pet stats sub-model with clamping to 0-100 range
class PetStats {
  final int hunger;
  final int happiness;
  final int health;

  PetStats({
    required int hunger,
    required int happiness,
    required int health,
  })  : hunger = hunger.clamp(0, 100),
        happiness = happiness.clamp(0, 100),
        health = health.clamp(0, 100);

  @override
  String toString() => 'Stats(H:$hunger Hp:$happiness Ht:$health)';
}
