import 'package:flutter/material.dart';

class AchievementBadgeWidget extends StatelessWidget {
  final String assetId;
  final double size;

  const AchievementBadgeWidget({
    super.key, 
    required this.assetId,
    this.size = 60.0,
  });

  @override
  Widget build(BuildContext context) {
    // Check if the assetId string contains a known file path
    // If you don't have the assets yet, default to the placeholder
    
    Widget badgeGraphic;

    switch (assetId) {
      // Add your real cases here later when you have the images
      // case 'badge_level_3':
      //   badgeGraphic = Image.asset('assets/badges/level_3.png');
      //   break;
      
      default:
        // FALLBACK PLACEHOLDER
        badgeGraphic = Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.amber.shade100,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.amber, width: 3),
          ),
          child: Icon(
            Icons.military_tech, // A generic badge icon
            color: Colors.amber.shade800,
            size: size * 0.6,
          ),
        );
    }

    return badgeGraphic;
  }
}