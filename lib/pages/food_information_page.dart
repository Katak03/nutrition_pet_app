import 'package:flutter/material.dart';
import '../models/food_model.dart';
import '../services/food_service.dart';
import '../widgets/food_card.dart';

class FoodInformationPage extends StatelessWidget {
  const FoodInformationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final FoodService foodService = FoodService();

    return Scaffold(
      backgroundColor: Colors.grey[100], // Soft grey background
      appBar: AppBar(
        title: const Text('Food Information'),
        backgroundColor: Colors.grey[100],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
        // Back button is automatically enabled by Flutter when pushed to Navigator
      ),
      body: StreamBuilder<List<FoodModel>>(
        stream: foodService.getFoodsStream(),
        builder: (context, snapshot) {
          // 1. Handle Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Handle Errors
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // 3. Handle Empty State
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No food information available.'));
          }

          // 4. Build the List
          final foods = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: foods.length,
            itemBuilder: (context, index) {
              return FoodCard(food: foods[index]);
            },
          );
        },
      ),
    );
  }
}