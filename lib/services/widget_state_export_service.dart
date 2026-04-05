import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/pet_model.dart';
import '../models/pet_snapshot_model.dart';
import '../repositary/pet_repository.dart';
import '../services/stat_decay_service.dart';
import '../services/pet_asset_resolver.dart';

/// Service to export the pet's current state to iOS App Groups UserDefaults
/// for display in home widget while the app is closed.
class WidgetStateExportService {
  final PetRepository _petRepository;

  // App Groups container key for iOS widget communication
  static const String _appGroupsKey = 'group.com.nutrition-game';
  static const String _snapshotStorageKey = 'com.group.nutrition-game.pet_snapshot';

  WidgetStateExportService({PetRepository? repository})
      : _petRepository = repository ?? PetRepository();

  /// Exports the current pet snapshot to iOS App Groups UserDefaults.
  ///
  /// This function should be called when the app enters background state.
  /// It retrieves the pet from Firestore, applies stat decay, resolves assets,
  /// and stores a JSON snapshot in the app group's shared container.
  ///
  /// Returns: true if successful, false otherwise
  /// Errors are logged to console but not thrown (graceful failure).
  Future<bool> exportPetSnapshot() async {
    try {
      // 1. Get the current user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('[WidgetExport] No user authenticated');
        return false;
      }

      // 2. Fetch the main pet from Firestore
      final petDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('pets')
          .doc('main_pet')
          .get();

      if (!petDoc.exists) {
        debugPrint('[WidgetExport] Main pet not found in Firestore');
        return false;
      }

      // 3. Convert to PetModel
      final pet = PetModel.fromFirestore(petDoc);

      // 4. Apply stat decay
      final decayedPet = StatDecayService.applyStatDecay(pet);

      // 5. Resolve asset based on current pet state
      // Note: asset_resolver requires daily logs, so we'll use a simplified version
      // that matches the priority order: sick > sad > hungry > happy
      final assetId = _resolveAssetForWidget(
        health: decayedPet.health,
        hunger: decayedPet.hunger,
        happiness: decayedPet.happiness,
      );

      // 6. Create the snapshot
      final snapshot = PetSnapshot(
        petId: pet.id,
        name: pet.assetId, // Using assetId as the name for widget display
        assetId: assetId,
        level: pet.level,
        xp: decayedPet.xp.toInt(),
        stats: PetStats(
          hunger: decayedPet.hunger,
          happiness: decayedPet.happiness,
          health: decayedPet.health,
        ),
        lastUpdate: DateTime.now().millisecondsSinceEpoch,
        lastFedAt: pet.lastFed.millisecondsSinceEpoch,
      );

      // 7. Write to App Groups UserDefaults
      // TODO: Write snapshot to App Groups UserDefaults using platform channels or alternative method.
      // Example: await _writeSnapshotToUserDefaults(snapshot);
      debugPrint('[WidgetExport] (TODO) Write snapshot to UserDefaults: $snapshot');
      return true;
    } catch (e) {
      debugPrint('[WidgetExport] Error exporting pet snapshot: $e');
      return false;
    }
  }

  /// Reads the pet snapshot from iOS App Groups UserDefaults.
  ///
  /// Returns: PetSnapshot if found, null otherwise
  Future<PetSnapshot?> readPetSnapshot() async {
    try {
      // TODO: Read snapshot from App Groups UserDefaults using platform channels or alternative method.
      debugPrint('[WidgetExport] (TODO) Read snapshot from UserDefaults');
      return null;
    } catch (e) {
      debugPrint('[WidgetExport] Error reading pet snapshot: $e');
      return null;
    }
  }

  /// Internal: Write snapshot JSON to iOS App Groups UserDefaults
  Future<void> _writeSnapshotToUserDefaults(PetSnapshot snapshot) async {
    // TODO: Implement platform channel logic for writing to UserDefaults
    debugPrint('[WidgetExport] (TODO) Platform channel write to UserDefaults');
  }

  /// Resolves the pet's asset string based on stat priority for widget display.
  ///
  /// Priority order (same as main app):
  /// 1. if health < 30 → "pet_sick"
  /// 2. else if happiness < 30 → "pet_sad"
  /// 3. else if hunger < 30 → "pet_hungry"
  /// 4. else → "pet_happy"
  ///
  /// All stats are expected to be 0-100 range.
  static String _resolveAssetForWidget({
    required int health,
    required int hunger,
    required int happiness,
  }) {
    if (health < 30) {
      return 'pet_sick';
    }

    if (happiness < 30) {
      return 'pet_sad';
    }

    if (hunger < 30) {
      return 'pet_hungry';
    }

    return 'pet_happy';
  }
}
