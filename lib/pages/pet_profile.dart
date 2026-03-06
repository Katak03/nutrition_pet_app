import 'package:flutter/material.dart';

// Assuming these match your project's import paths
import '../models/pet_model.dart';
import '../services/gamification_service.dart';
import '../services/achievement_service.dart';
import '../widgets/pet_display_widget.dart';
import '../widgets/achievement_badge_widget.dart';

class PetProfile extends StatefulWidget {
  final GamificationService gamificationService;
  final AchievementService achievementService;

  const PetProfile({
    Key? key,
    required this.gamificationService,
    required this.achievementService,
  }) : super(key: key);

  @override
  State<PetProfile> createState() => _PetProfileState();
}

class _PetProfileState extends State<PetProfile> {
  late Future<PetModel?> _petFuture;
  late Future<List<Map<String, dynamic>>> _achievementsFuture;

  @override
  void initState() {
    super.initState();
    // 1. UI calls Services only. No Firestore access here.
    _petFuture = widget.gamificationService.getMainPet();
    _achievementsFuture = widget.achievementService.getAchievements();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            
            // --- PET INFO & STATS SECTION ---
            FutureBuilder<PetModel?>(
              future: _petFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(color: Colors.green),
                  );
                }
                
                if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                  return const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text("Failed to load pet data."),
                  );
                }

                final pet = snapshot.data!;
                return Column(
                  children: [
                    const SizedBox(height: 24),
                    
                    // Center Avatar
                    PetDisplayWidget(pet: pet),
                    
                    const SizedBox(height: 16),
                    
                    // Pet Name & Level
                    Text(
                      "Pet Level ${pet.level}",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Level ${pet.level}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade700,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Middle Stats Card
                    _buildStatsCard(pet),
                  ],
                );
              },
            ),
            
            const SizedBox(height: 32),

            // --- ACHIEVEMENTS SECTION ---
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _achievementsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(color: Colors.green);
                }
                
                if (snapshot.hasError || !snapshot.hasData) {
                  return const Text("Failed to load achievements.");
                }

                final achievements = snapshot.data!;
                
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Achievement",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Achievements Grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.8, // Adjusts height for text below icon
                        ),
                        itemCount: achievements.length,
                        itemBuilder: (context, index) {
                          final ach = achievements[index];
                          final bool isUnlocked = ach['isUnlocked'] ?? false;
                          
                          // Wrap the badge in ColorFiltered to grey it out if locked
                          Widget badge = AchievementBadgeWidget(
                            assetId: ach['assetId'] ?? 'placeholder',
                          );

                          if (!isUnlocked) {
                            badge = ColorFiltered(
                              colorFilter: const ColorFilter.matrix([
                                0.2126, 0.7152, 0.0722, 0, 0,
                                0.2126, 0.7152, 0.0722, 0, 0,
                                0.2126, 0.7152, 0.0722, 0, 0,
                                0,      0,      0,      1, 0,
                              ]), // Standard greyscale matrix
                              child: Opacity(
                                opacity: 0.6,
                                child: badge,
                              ),
                            );
                          }

                          return Column(
                            children: [
                              badge,
                              const SizedBox(height: 8),
                              Text(
                                ach['title'] ?? 'Unknown',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 12),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 40), // Bottom padding
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- UI HELPER METHODS ---

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 20,
        left: 16,
        right: 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              "Pet Info",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 48), // Balances the back button for perfect centering
        ],
      ),
    );
  }

  Widget _buildStatsCard(PetModel pet) {
    // Use direct pet properties from PetModel
    final totalScore = (pet.xp * 10).toInt(); // Convert XP to score

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      shadowColor: Colors.black12,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatColumn("Total XP", pet.xp.toInt().toString()),
            _buildDivider(),
            _buildStatColumn("Streak", pet.streaks.toString()),
            _buildDivider(),
            _buildStatColumn("Total Score", totalScore.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey.shade300,
    );
  }
}