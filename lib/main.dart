import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart'; 

// --- 1. ADD MISSING ENGINE IMPORT ---
import 'package:nutrition_game/utils/achievement_engine.dart'; 
import 'package:nutrition_game/services/achievement_service.dart';
import 'package:nutrition_game/repositary/achievement_repositary.dart'; // Assuming this is your spelling!
import 'package:nutrition_game/utils/firebase_keys.dart';
import 'package:nutrition_game/services/widget_projection_service.dart';
import 'package:nutrition_game/services/widget_state_export_service.dart';
import 'package:nutrition_game/models/pet_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'pages/login_page.dart';
import 'pages/home_page.dart';

// --- 2. PROPERLY WIRE THE ARCHITECTURE TOGETHER ---
final AchievementRepository achievementRepo = AchievementRepository();
final AchievementService achievementService = AchievementService(achievementRepo);
final AchievementEngine achievementEngine = AchievementEngine(achievementService);

// --- 3. APP LIFECYCLE OBSERVER FOR HOME WIDGET ---
class _AppLifecycleObserver extends WidgetsBindingObserver {
  final Future<PetModel?> Function() getCurrentPet;
  final WidgetStateExportService _widgetExportService = WidgetStateExportService();
  
  _AppLifecycleObserver({required this.getCurrentPet});
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused) {
      // App going to background — export current pet state to iOS widget
      debugPrint('[Lifecycle] App entering background, exporting pet snapshot...');
      final success = await _widgetExportService.exportPetSnapshot();
      if (success) {
        debugPrint('[Lifecycle] Pet snapshot exported successfully for widget display');
      } else {
        debugPrint('[Lifecycle] Failed to export pet snapshot (will retry on next background)');
      }
    }
    if (state == AppLifecycleState.resumed) {
      // App came back — Firebase listener will fire and overwrite with real value
      debugPrint('[Lifecycle] App resumed from background');
    }
  }
}

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
  late _AppLifecycleObserver _lifecycleObserver;

  @override
  void initState() {
    super.initState();
    // Initialize lifecycle observer for home widget timeline updates
    _lifecycleObserver = _AppLifecycleObserver(
      getCurrentPet: _getCurrentPetFromFirebase,
    );
    WidgetsBinding.instance.addObserver(_lifecycleObserver);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_lifecycleObserver);
    super.dispose();
  }

  // Fetch current pet from Firestore
  Future<PetModel?> _getCurrentPetFromFirebase() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('pets')
          .doc(FB.mainPetId)
          .get();
      
      if (doc.exists) {
        return PetModel.fromFirestore(doc);
      }
    } catch (e) {
      debugPrint('Error fetching pet for widget: $e');
    }
    return null;
  }

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