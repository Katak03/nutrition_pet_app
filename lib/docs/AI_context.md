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

### stat_decay_service.dart
Handles:
- Time-based stat reduction
- Uses last interaction timestamp

### pet_repository.dart
Acts as Firestore data access layer for pet data.

### pet_asset_resolver.dart
Determines pet image/state based on stats.

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
- food_card.dart
- food_vertical_slider.dart
- macro_card.dart
- vitamin_progress_bar.dart

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

# 🗄️ Firebase Structure (Conceptual)

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
   - gamification (Map): { streaks, totalScore }
   - timestamps (Map): { lastFed, lastInteraction }

4. SUB-COLLECTION: users/{uid}/unlocked_achievements (Doc ID: "achievement_id")
   - earnedAt (timestamp)
   - rewardClaimed (boolean)

5. COLLECTION: foods (Doc ID: unique_food_id)
   - name, calories, macros, vitamins, petEffect, assetId

6. COLLECTION: Achievement (Doc ID: achievement_id)
	-assetId, 
	-criteria(Map):{type, level, operator },
	-description,
	- title

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

---

# 🤖 Instructions For AI Assistants

When helping this project:

1. Respect architecture layers.
2. Do NOT move Firebase logic into UI.
3. Prefer modifying services instead of pages.
4. Maintain separation of concerns.
5. Firestore remains single source of truth.

Always assume this structure unless stated otherwise.