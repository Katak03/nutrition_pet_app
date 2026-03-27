import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pet_model.dart';
import '../models/daily_log_model.dart';
import '../services/pet_asset_resolver.dart';

class PetDisplayWidget extends StatefulWidget {
  final PetModel pet;

  const PetDisplayWidget({super.key, required this.pet});

  @override
  State<PetDisplayWidget> createState() => _PetDisplayWidgetState();
}

class _PetDisplayWidgetState extends State<PetDisplayWidget> {
  late Future<List<DailyLogModel>> _logsFuture;

  @override
  void initState() {
    super.initState();
    _logsFuture = _fetchRecentLogs();
  }

  Future<List<DailyLogModel>> _fetchRecentLogs() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final db = FirebaseFirestore.instance;
    final now = DateTime.now();
    final dates = List.generate(3, (i) => now.subtract(Duration(days: i)).toIso8601String().split('T').first);

    final logs = <DailyLogModel>[];
    for (final date in dates) {
      final doc = await db.collection('users').doc(uid).collection('daily_logs').doc(date).get();
      if (doc.exists) {
        logs.add(DailyLogModel.fromFirestore(doc));
      }
    }
    return logs;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DailyLogModel>>(
      future: _logsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return const Icon(Icons.pets, size: 150, color: Colors.grey);
        }

        final logs = snapshot.data ?? [];
        final currentLog = logs.isNotEmpty ? logs.first : null; // assume first is today
        final recentLogs = logs;

        final assetName = currentLog != null ? PetAssetResolver.resolveAsset(
          health: widget.pet.health,
          hunger: widget.pet.hunger,
          happiness: widget.pet.happiness,
          log: currentLog,
          recentLogs: recentLogs,
        ) : 'happy'; // default if no log

        // Map assetName to actual image paths
        String imagePath;
        switch (assetName) {
          case 'happy':
            imagePath = 'lib/images/pet_happy.png';
            break;
          case 'sad':
            imagePath = 'lib/images/pet_sad.png';
            break;
          case 'hungry':
            imagePath = 'lib/images/pet_hungry.png';
            break;
          case 'sick':
            imagePath = 'lib/images/pet_sick.png';
            break;
          case 'def_a':
            imagePath = 'lib/images/pet_defA.png';
            break;
          case 'def_b1':
            imagePath = 'lib/images/pet_defB1.png';
            break;
          case 'def_b2':
            imagePath = 'lib/images/pet_defB2.png';
            break;
          case 'def_c':
            imagePath = 'lib/images/pet_defC.png';
            break;
          default:
            imagePath = 'lib/images/pet_happy.png';
        }

        return Column(
          children: [
            Image.asset(
              imagePath,
              height: 200,
              width: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.pets,
                size: 150,
                color: Colors.grey,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // This will still print "Status: HAPPY PET" on the screen so you can test if feeding works!
            Text(
              'Status: ${assetName.replaceAll('_', ' ').toUpperCase()}', 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        );
      },
    );
  }
}