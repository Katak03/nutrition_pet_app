import 'package:flutter/material.dart';
import '../models/food_model.dart';

class FoodCard extends StatelessWidget {
  final FoodModel food;
  final VoidCallback? onFeed; // 1. Added this optional callback

  // 2. Added this.onFeed to the constructor
  const FoodCard({super.key, required this.food, this.onFeed}); 

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      color: Colors.white,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Food Name at the top left
            Text(
              food.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            
            // Horizontal layout for Image and Stats
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LEFT SIDE: Image Placeholder
                Image.asset(
                  'assets/images/placeholder.png', 
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.fastfood,
                    size: 80,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 16),
                
                // RIGHT SIDE: Stats organized in columns
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Column 1: Macros
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStatText('Protein', '${food.protein}g'),
                          const SizedBox(height: 8),
                          _buildStatText('Carbs', '${food.carbs}g'),
                          const SizedBox(height: 8),
                          _buildStatText('Fats', '${food.fats}g'),
                        ],
                      ),
                      
                      // Column 2: Calories & Vits A/B1
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStatText('Calorie', '${food.calories}'),
                          const SizedBox(height: 8),
                          _buildStatText('A', '${food.vitA}mcg'),
                          const SizedBox(height: 8),
                          _buildStatText('B1', '${food.vitB1}mg'),
                        ],
                      ),

                      // Column 3: Vits C/B2
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStatText('C', '${food.vitC}mg'),
                          const SizedBox(height: 8),
                          _buildStatText('B2', '${food.vitB2}mg'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // 3. ADDED THIS: Conditionally show a Feed button!
            if (onFeed != null) ...[
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: onFeed,
                  icon: const Icon(Icons.pets),
                  label: const Text('Feed Pet'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange, // Fun pet color
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
            
          ],
        ),
      ),
    );
  }

  // Helper widget to format the text neatly
  Widget _buildStatText(String label, String value) {
    return Text(
      '$label: $value',
      style: const TextStyle(
        fontSize: 13,
        color: Colors.black87,
      ),
    );
  }
}