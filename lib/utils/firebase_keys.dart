class FB {
  // Top Level Collections
  static const String users = 'users';
  static const String foods = 'foods';
  static const String achievements = 'achievements';

  // Subcollections
  static const String mainPetId = 'main_pet';
  static const String pets = 'pets';
  static const String dailyLogs = 'daily_logs';
  static const String unlockedAchievements = 'unlocked_achievements';

  // User Fields
  static const String username = 'username';
  static const String email = 'email';
  static const String createdAt = 'createdAt';
  static const String profile = 'profile';
  static const String nutritionGoals = 'nutritionGoals';

  // Food Fields
  static const String searchKeywords = 'searchKeywords';
  static const String foodID = 'foodID'; // Used in daily_logs
  
  // Profile Map Keys
  static const String age = 'age';
  static const String sex = 'sex';
  static const String height = 'height';
  static const String weight = 'weight';
  static const String activityLevel = 'activityLevel';
  static const String goalType = 'goalType';

  // Nutrition & Macros
  static const String dailyCalories = 'dailyCalories';
  static const String calories = 'calories';
  static const String protein = 'protein';
  static const String carbs = 'carbs';
  static const String fats = 'fats';
  static const String water = 'water';

  // Vitamins (Handling both formats from your JSON)
  static const String vitamins = 'vitamins';
  static const String vitA = 'a';
  static const String vitB12 = 'b12';
  static const String vitC = 'c';
  static const String vitD = 'd';
  // Specific keys found in 'Foods' collection
  static const String vitA_full = 'vitamin_a';
  static const String vitB12_full = 'vitamin_b12';
  static const String vitC_full = 'vitamin_c';
  static const String vitD_full = 'vitamin_d';

  // Pet Fields
  static const String name = 'name';
  static const String assetId = 'assetId';
  static const String level = 'level';
  static const String xp = 'xp';
  
  // Pet Nested Maps
  static const String stats = 'stats';
  static const String timestamps = 'timestamps';
  static const String gamification = 'gamification';

  // Stats Keys
  static const String happiness = 'happiness';
  static const String hunger = 'hunger';
  static const String health = 'health';
  
  // Handling the naming mismatch (singular vs plural)
  static const String petEffect = 'petEffect';   // Used in Foods
  static const String petEffects = 'petEffects'; // Used in Daily Logs

  // Timestamp Keys
  static const String lastFed = 'lastFed';
  static const String lastInteraction = 'lastInteraction';

  // Gamification Keys
  static const String streaks = 'streaks';
  static const String totalScore = 'totalScore';

//achievement fields
static const String earnedAt = "earnedAt";
static const String rewardClaimed = "rewardClaimed";
}