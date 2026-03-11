// food_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FoodModel {
  final String id;
  final String name;
  final num calories;
  final Map<String, dynamic> macros;
  final Map<String, dynamic> vitamins;
  final Map<String, dynamic> petEffect; 
  final String assetId;

  FoodModel({
    required this.id,
    required this.name,
    required this.calories,
    required this.macros,
    required this.vitamins,
    required this.petEffect,
    required this.assetId,
  });

  // Macros match your Firestore keys (protein, carbs, fats)
  num get protein => macros['protein'] ?? 0;
  num get carbs => macros['carbs'] ?? 0;
  num get fats => macros['fats'] ?? 0;

  // UPDATED: These must match the "vitamin_" prefix found in your Firestore
  num get vitA => vitamins['vitamin_a'] ?? 0;
  num get vitB1 => vitamins['vitamin_b1'] ?? 0;
  num get vitC => vitamins['vitamin_c'] ?? 0;
  num get vitB2 => vitamins['vitamin_b2'] ?? 0;

  factory FoodModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};

    return FoodModel(
      id: doc.id,
      name: data['name'] ?? 'Unknown Food',
      calories: data['calories'] ?? 0,
      macros: data['macros'] ?? {},
      vitamins: data['vitamins'] ?? {},
      petEffect: data['petEffect'] ?? {}, 
      assetId: data['assetId'] ?? 'placeholder',
    );
  }
}