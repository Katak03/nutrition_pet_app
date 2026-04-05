# 🧠 AI PROJECT CONTEXT
Project Name: Nutrition Game (Virtual Pet Nutrition App)

Framework: Flutter  
Backend: Firebase Authentication + Cloud Firestore  
Architecture Style: Layered (UI → Service → Repository → Firebase)

---

# 📱 Application Overview
Nutrition Game is a gamified nutrition tracking application where users maintain a virtual pet.

Pet status depends on:
- Food consumed
- Nutrition intake
- Time-based stat decay

Main gameplay loop:
User eats food → feeds pet → pet stats update → pet appearance changes.

---

# 🏗️ Project Architecture

## Folder Structure

lib/
│
├── models/      → Data models
├── pages/       → Application screens (UI Layer)
├── services/    → Business logic & Firebase operations
├── widgets/     → Reusable UI components
├── utils/       → Helpers & constants
└── docs/        → AI documentation

---

# 🧩 Architecture Layers

## 1️⃣ UI Layer (pages/)
Responsible for:
- Displaying data
- User interaction
- Navigation
- Calling services

Pages:
- home_page.dart
- login_page.dart
- register_page.dart
- pet_screen.dart
- pet_profile.dart
- food_information_page.dart
- profile_dashboard.dart

UI should NOT directly access Firestore.

---

## 2️⃣ Service Layer (services/)
Core application logic.

### auth_service.dart
Handles:
- Login
- Register
- Firebase authentication

### user_profile_service.dart
Handles:
- User profile retrieval
- Profile updates

### food_service.dart
Handles:
- Food fetching
- Nutrition data access

### feed_pet_service.dart
Handles:
- Feeding logic
- Stat increase after eating
- Pet interaction tracking

### stat_decay_service.dart
Handles:
- Time-based stat reduction
- Uses last interaction timestamp

### gamification_service.dart (NEW)
Handles:
- XP and level system
- Gamification progression
- Reward calculations

### achievement_service.dart (NEW)
Handles:
- Achievement tracking
- Achievement unlocking logic
- Achievement reward claiming

### passive_xp_handler.dart (NEW)
Handles:
- Background XP generation
- Time-based progression
- Passive reward mechanics

### nutrition_alert_service.dart (NEW)
Handles:
- Nutrition goal notifications
- Health alerts
- Dietary warnings

### anti_cheat_guard.dart (NEW)
Handles:
- Anti-cheat validation
- Data integrity checks
- Fraudulent activity detection

### widget_projection_service.dart (NEW)
Handles:
- Widget state projection
- UI state calculation
- Widget rendering optimization

### widget_state_export_service.dart (NEW)
Handles:
- Pet state snapshot export for iOS widget
- App Groups UserDefaults communication
- Stat decay calculation before export
- Asset resolution for widget display
- Called on app background via lifecycle observer

### pet_asset_resolver.dart
Determines pet image/state based on stats.

### pet_repository.dart
Acts as Firestore data access layer for pet data.

---

## 3️⃣ Model Layer (models/)

### user_model.dart
Represents application user.

### pet_model.dart
Pet attributes:
- hunger
- happiness
- health
- lastInteraction

### food_model.dart
Food nutrition information:
- calories
- protein
- carbs
- fats
- vitamins

### daily_log_model.dart
Stores daily nutrition tracking.

---

## 4️⃣ Widget Layer (widgets/)
Reusable UI components.

Widgets:
- pet_display_widget.dart
- pet_stat_bar.dart
- pet_speech_bubble.dart
- food_card.dart
- food_vertical_slider.dart
- macro_card.dart
- vitamin_progress_bar.dart
- achievement_badge_widget.dart
- level_up_overlay.dart

Widgets must remain UI-only.

---

# 🔥 Pet System Logic

## Pet Stats
Main stats:
- Hunger
- Happiness
- Health

Rules:
- Stats decay over time
- Feeding increases hunger & happiness
- Health derived from nutrition quality
- Firestore is source of truth

Stat update flow:

UI  
→ feed_pet_service  
→ pet_repository  
→ Firestore update  
→ Stream/UI rebuild

---

# 🏆 Gamification System (NEW)

## XP & Level System
- Pet gains XP from feeding events
- XP determines pet level progression
- Level-up triggers achievement checks
- Passive XP generation from time-based progression

## Achievement System
- Master achievements stored in `achievements` collection
- User unlocked achievements in `users/{uid}/unlocked_achievements`
- Achievements tracked by criteria (type, level, operator)
- Rewards assigned upon achievement unlock
- `rewardClaimed` status tracks reward redemption

## Passive XP Handler
- Generates XP passively over time
- Uses `lastXpUpdate` timestamp to calculate earned XP
- Prevents duplicate XP awards via anti-cheat

## Anti-Cheat Guard
- Validates data integrity before updates
- Detects fraudulent XP or stat changes
- Ensures stat decay calculations are legitimate
- Prevents manipulation of timestamps

## Nutrition Alerts
- Sends alerts for nutrition goal deviations
- Monitors daily macro/vitamin intake
- Provides health warnings based on pet nutrition
- Integrates with daily log tracking

---

# � iOS Widget Integration (NEW)

## Widget State Export
- `WidgetStateExportService` exports pet snapshot to iOS widget
- Triggered automatically when app enters background (via AppLifecycleState.paused)
- Uses App Groups UserDefaults for cross-process communication
- Key: `com.group.nutrition-game.pet_snapshot`

## Widget Data Flow
1. App enters background
2. _AppLifecycleObserver detects AppLifecycleState.paused
3. exportPetSnapshot() is called
4. Fetches main pet from Firestore
5. Applies stat decay
6. Resolves asset based on pet health/hunger/happiness
7. Creates PetSnapshot JSON
8. Writes to App Groups UserDefaults
9. iOS widget reads snapshot and updates display

## PetSnapshot Model
JSON structure stored in UserDefaults:
```json
{
  "petId": "main_pet",
  "name": "pet_happy",
  "assetId": "pet_happy",
  "level": 5,
  "xp": 1250,
  "stats": {
    "hunger": 85,
    "happiness": 92,
    "health": 88
  },
  "lastUpdate": 1680000000000,
  "lastFedAt": 1679900000000
}
```

## Asset Resolution for Widget
Priority order (same as main app):
1. if health < 30 → "pet_sick"
2. else if happiness < 30 → "pet_sad"
3. else if hunger < 30 → "pet_hungry"
4. else → "pet_happy"

---

# �🗄️ Firebase Structure (Conceptual)

*** MASTER FIREBASE SCHEMA ***
Use this exact structure for all code generation.

1. COLLECTION: users (Doc ID: Auth UID)
   - username (string)
   - email (string)
   - createdAt (timestamp)
   - profile (Map): { age, sex, height, weight, activityLevel, goalType }
   - nutritionGoals (Map): { dailyCalories, protein, carbs, fats }

2. SUB-COLLECTION: users/{uid}/daily_logs (Doc ID: "YYYY-MM-DD")
   - totalCalories (number)
   - water (number)
   - macros (Map): { protein, carbs, fats }
   - vitamins (Map): { a, b12, c, d }
   - foodEntries (Array of Maps):
     - { foodID, name, calories, macros: {p,c,f}, petEffects: {happiness, health, hunger} }

3. SUB-COLLECTION: users/{uid}/pets (Doc ID: "pet_id")
   - name (string)
   - assetId (string) 
   - level (number)
   - xp (number)
   - stats (Map): { happiness, hunger, health }
   - gamification (Map): { streaks, totalScore, levelUpCount }
   - timestamps (Map): { lastFed, lastInteraction, lastXpUpdate, passiveXpLastUpdate }

4. SUB-COLLECTION: users/{uid}/unlocked_achievements (Doc ID: "achievement_id")
   - earnedAt (timestamp)
   - rewardClaimed (boolean)
   - achievementId (string)

5. COLLECTION: foods (Doc ID: unique_food_id)
   - name, calories, macros, vitamins, petEffect, assetId

6. COLLECTION: achievements (Master Achievement List) (Doc ID: achievement_id)
   - id (string)
   - title (string)
   - description (string)
   - assetId (string)
   - criteria (Map): { type, level, operator }
   - reward (Map): { xp, coins, badge }

*** END SCHEMA ***

# 🔄 Data Flow

Firestore
   ↓
Repository
   ↓
Service Logic
   ↓
UI Pages
   ↓
Widgets

All database communication MUST go through services/repository.

---

# ⚙️ State Management
Current approach:
- setState()
- FutureBuilder / StreamBuilder

Firestore acts as reactive data source.

---

# 📏 Development Rules

✅ Pages call Services  
✅ Services call Repository  
✅ Repository accesses Firestore  

❌ UI must not directly read/write Firestore  
❌ Widgets must not contain business logic  

---

# 🚨 Known Core Systems
- Time-based stat decay
- Pet appearance resolver
- Nutrition-based gameplay
- Firebase-driven persistence
- XP and leveling system (gamification_service)
- Achievement tracking and rewards (achievement_service)
- Passive XP generation (passive_xp_handler)
- Anti-cheat validation (anti_cheat_guard)
- Nutrition alerts and health monitoring (nutrition_alert_service)
- Widget state projection (widget_projection_service)

---

# 🤖 Instructions For AI Assistants

When helping this project:

1. Respect architecture layers.
2. Do NOT move Firebase logic into UI.
3. Prefer modifying services instead of pages.
4. Maintain separation of concerns.
5. Firestore remains single source of truth.

Always assume this structure unless stated otherwise.