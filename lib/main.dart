import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart'; 

// --- 1. ADD MISSING ENGINE IMPORT ---
import 'package:nutrition_game/utils/achievement_engine.dart'; 
import 'package:nutrition_game/services/achievement_service.dart';
import 'package:nutrition_game/repositary/achievement_repositary.dart'; // Assuming this is your spelling!
import 'package:nutrition_game/utils/firebase_keys.dart';

import 'pages/login_page.dart';
import 'pages/home_page.dart';

// --- 2. PROPERLY WIRE THE ARCHITECTURE TOGETHER ---
final AchievementRepository achievementRepo = AchievementRepository();
final AchievementService achievementService = AchievementService(achievementRepo);
final AchievementEngine achievementEngine = AchievementEngine(achievementService);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nutrition Game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green, 
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _engineStarted = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;

        // USER LOGGED IN
        if (user != null) {
          if (!_engineStarted) {
            achievementEngine.startEngine(
              user.uid,
              FB.mainPetId, 
            );

            _engineStarted = true;
          }

          return const HomePage();
        }

        // USER LOGGED OUT
        if (_engineStarted) {
          achievementEngine.disposeEngine();
          _engineStarted = false;
        }

        return const LoginPage();
      },
    );
  }
}