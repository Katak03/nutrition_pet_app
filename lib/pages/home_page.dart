import 'package:flutter/material.dart';
// Import your auth service to handle logging out
import '../services/auth_service.dart';
import '../services/gamification_service.dart';
import '../services/achievement_service.dart';
import '../repositary/gamification_repositary.dart';
import '../repositary/achievement_repositary.dart';
import 'food_information_page.dart';
import 'pet_screen.dart';
import 'profile_dashboard.dart';
import 'pet_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition Game Dashboard'),
        actions: [
          // A convenient logout icon in the top right corner
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().signOut();
              // No need to write navigation code here! 
              // AuthGate in main.dart handles the redirect to LoginPage.
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.health_and_safety, size: 80, color: Colors.green),
            const SizedBox(height: 30),

            // 1. Main Page Button

            ElevatedButton.icon(
              icon: const Icon(Icons.pets),
              label: const Text('Pet Page'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    
                    builder: (context) => PetScreen(petId: 'main_pet'), 
                  ),
                );
              }
            ),

            // 2. User Profile Button
            // 2. User Profile Button
            ElevatedButton.icon(
              icon: const Icon(Icons.person),
              label: const Text('User Profile'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
              onPressed: () {
                // FIX: Define currentUid right here before using it
                final String? currentUid = FirebaseAuth.instance.currentUser?.uid;

                if (currentUid != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(userId: currentUid), 
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error: You must be logged in!')),
                  );
                }
              },
            ),
            const SizedBox(height: 16),
        

            // 3. Pet Profile Button
            ElevatedButton.icon(
              icon: const Icon(Icons.pets),
              label: const Text('Pet Profile'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
              onPressed: () {
                final gamificationRepo = GamificationRepository(uid: FirebaseAuth.instance.currentUser?.uid ?? '');
                final gamificationService = GamificationService(gamificationRepo);
                final achievementRepo = AchievementRepository();
                final achievementService = AchievementService(achievementRepo);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PetProfile(
                      gamificationService: gamificationService,
                      achievementService: achievementService,
                    ),
                  ),
                );
              },
            ),


            // 4. Nutrition Information Button
            ElevatedButton.icon(
              icon: const Icon(Icons.restaurant_menu),
              label: const Text('Nutrition Information'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
              onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FoodInformationPage(),
                ),
              );
},
            ),
            const SizedBox(height: 32),

            // 5. Logout Button (Big red button at the bottom)
            OutlinedButton.icon(
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text('Logout', style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                side: const BorderSide(color: Colors.red),
              ),
              onPressed: () async {
                await AuthService().signOut();
                // AuthGate in main.dart will automatically redirect you
              },
            ),
          ],
        ),
      ),
    );
  }
}