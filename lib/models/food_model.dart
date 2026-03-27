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
  final String type; // food, drink, snack
  final num sugar;

  FoodModel({
    required this.id,
    required this.name,
    required this.calories,
    required this.macros,
    required this.vitamins,
    required this.petEffect,
    required this.assetId,
    this.type = 'food',
    this.sugar = 0,
  });

  // Macros match your Firestore keys (protein, carbs, fats)
  num get protein => macros['protein'] ?? 0;
  num get carbs => macros['carbs'] ?? 0;
  num get fats => macros['fats'] ?? 0;

  // Read vitamins from the new Firestore structure (a, b1, c, b2)
  // Defaults to 0 if missing (null safety)
  num get vitA => vitamins['a'] ?? 0;
  num get vitB1 => vitamins['b1'] ?? 0;
  num get vitC => vitamins['c'] ?? 0;
  num get vitB2 => vitamins['b2'] ?? 0;

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
      type: data['type'] ?? 'food',
      sugar: data['sugar'] ?? 0,
    );
  }
}