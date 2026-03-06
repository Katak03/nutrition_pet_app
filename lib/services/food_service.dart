import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/food_model.dart';

class FoodService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Real-time stream of foods
  Stream<List<FoodModel>> getFoodsStream() {
    return _firestore.collection('foods').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => FoodModel.fromFirestore(doc)).toList();
    });
  }
}