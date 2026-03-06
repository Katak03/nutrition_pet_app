import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/food_model.dart';
import '../models/pet_model.dart';
import '../repositary/pet_repository.dart';
import '../services/feed_pet_service.dart';
import '../repositary/gamification_repositary.dart';
import '../services/gamification_service.dart';
import '../widgets/food_card.dart';
import '../widgets/level_up_overlay.dart';

class FoodVerticalSlider extends StatelessWidget {
  final PetModel currentPet;
  final FoodRepository foodRepo = FoodRepository();
  late final FeedPetService feedService;

  FoodVerticalSlider({super.key, required this.currentPet}) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final gamificationRepo = GamificationRepository(uid: user.uid);
      final gamificationService = GamificationService(gamificationRepo);
      feedService = FeedPetService(gamificationService);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Please log in to feed your pet'));
    }

    return StreamBuilder<List<FoodModel>>(
      stream: foodRepo.streamFoods(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        
        final foods = snapshot.data!;
        
        return ListView.builder(
          itemCount: foods.length,
          itemBuilder: (context, index) {
            final food = foods[index];
            return FoodCard(
              food: food,
              onFeed: () => feedService.feedPet(
                currentPet,
                food,
                onLevelUp: (oldLevel, newLevel) {
                  LevelUpManager.show(
                    context,
                    oldLevel: oldLevel,
                    newLevel: newLevel,
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}