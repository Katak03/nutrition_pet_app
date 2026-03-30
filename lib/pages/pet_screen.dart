import 'package:flutter/material.dart';
import '../models/pet_model.dart';
import '../repositary/pet_repository.dart';
import '../services/nutrition_alert_service.dart';
import '../services/widget_projection_service.dart';
import '../widgets/pet_display_widget.dart';
import '../widgets/pet_stat_bar.dart';
import '../widgets/food_vertical_slider.dart';
import '../widgets/pet_speech_bubble.dart';

class PetScreen extends StatefulWidget {
  final String petId;
  const PetScreen({super.key, required this.petId});

  @override
  State<PetScreen> createState() => _PetScreenState();
}

class _PetScreenState extends State<PetScreen> {
  final PetRepository _petRepo = PetRepository();
  final NutritionAlertService _nutritionAlertService = NutritionAlertService();
  String? _bubbleMessage;
  bool _showBubble = true;

  @override
  void initState() {
    super.initState();
    _syncDecayOnLoad();
    _checkNutritionAlert();
  }

  // Calculate and save decay exactly once when screen opens
  Future<void> _syncDecayOnLoad() async {
    final streamDoc = await _petRepo.streamPet(widget.petId).first;
    await _petRepo.saveDecayedStats(streamDoc);
  }

  // Check for nutrition alerts and get message if needed
  Future<void> _checkNutritionAlert() async {
    final message = await _nutritionAlertService.getRandomNutrientMessage();
    if (mounted) {
      setState(() {
        _bubbleMessage = message;
        _showBubble = message != null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Pet')),
      body: StreamBuilder<PetModel>(
        stream: _petRepo.streamPet(widget.petId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData) return const Center(child: Text('Pet not found'));

          final pet = snapshot.data!;
          
          

          return Column(
            children: [
              const SizedBox(height: 20),
              // Pet display with speech bubble
              if (_showBubble && _bubbleMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  child: PetSpeechBubble(
                    message: _bubbleMessage!,
                    onDismiss: () {
                      setState(() => _showBubble = false);
                    },
                  ),
                ),
              PetDisplayWidget(pet: pet),
              
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    PetStatBar(label: 'Health', value: pet.health, color: Colors.red),
                    PetStatBar(label: 'Hunger', value: pet.hunger, color: Colors.orange),
                    PetStatBar(label: 'Happiness', value: pet.happiness, color: Colors.green),
                  ],
                ),
              ),

              const Divider(),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Feed your pet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              
              // Feature 3: Vertical Food Slider
              Expanded(
                child: FoodVerticalSlider(currentPet: pet),
              ),
            ],
          );
        },
      ),
    );
  }
}