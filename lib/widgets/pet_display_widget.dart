import 'package:flutter/material.dart';
import '../models/pet_model.dart';
import '../services/pet_asset_resolver.dart';

class PetDisplayWidget extends StatelessWidget {
  final PetModel pet;

  const PetDisplayWidget({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    // This still calculates if the pet SHOULD be happy/sad/hungry in the background
    final assetName = PetAssetResolver.resolveAsset(
      health: pet.health, 
      hunger: pet.hunger, 
      happiness: pet.happiness
    );

    return Column(
      children: [
        // ---------------------------------------------------------
        // USE THIS LATER: When you have the actual pet images
        // ---------------------------------------------------------
        // Image.asset(
        //   'assets/pets/$assetName.png', 
        //   height: 200, 
        //   errorBuilder: (c, e, s) => const Icon(Icons.pets, size: 100),
        // ),

        // ---------------------------------------------------------
        // USING THIS NOW: Safe placeholder image
        // ---------------------------------------------------------
        Image.asset(
          'assets/images/placeholder.png', 
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
  }
}