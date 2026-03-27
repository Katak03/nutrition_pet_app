// profile_dashboard.dart
import 'package:flutter/material.dart';
import '../services/user_profile_service.dart';
import '../models/user_model.dart';
import '../models/daily_log_model.dart';

class ProfilePage extends StatefulWidget {
  final String userId;

  const ProfilePage({super.key, required this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final UserProfileService _fs;

  @override
  void initState() {
    super.initState();
    _fs = UserProfileService(uid: widget.userId);
    // Initialize today's log structure in Firestore
    _fs.initializeTodayLog();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F7),
      appBar: AppBar(
        title: const Text("Profile", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<UserModel>(
        stream: _fs.streamUser(),
        builder: (context, userSnap) {
          if (!userSnap.hasData) return const Center(child: CircularProgressIndicator());
          final user = userSnap.data!;

          return StreamBuilder<DailyLogModel>(
            stream: _fs.streamTodayLog(),
            builder: (context, logSnap) {
              final log = logSnap.data ?? DailyLogModel.empty(DateTime.now());

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Header
                    Center(
                      child: Column(
                        children: [
                          const CircleAvatar(radius: 50, backgroundColor: Color(0xFF4CAF50), child: Icon(Icons.person, size: 50, color: Colors.white)),
                          const SizedBox(height: 10),
                          Text(user.username, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          Text(user.email, style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // 2. Weekly Chart
                    const Text("Total Daily Calories", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    _buildWeeklyChart(user.nutritionGoals.dailyCalories),
                    const SizedBox(height: 25),

                    // 3. Calories Progress
                    _buildCalorieCard(log.totalCalories, user.nutritionGoals.dailyCalories),
                    const SizedBox(height: 20),

                    // 4. Macro Grid (Circular Design from Mock 4.png)
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 1.4,
                      children: [
                        _buildCircularMacro("Protein", log.macros['protein']!, user.nutritionGoals.protein, Colors.pinkAccent, "gram"),
                        _buildCircularMacro("Fats", log.macros['fats']!, user.nutritionGoals.fats, Colors.deepPurpleAccent, "gram"),
                        _buildCircularMacro("Carbs", log.macros['carbs']!, user.nutritionGoals.carbs, Colors.orange, "gram"),
                        _buildCircularMacro("Water", log.water, 6, Colors.blueAccent, "glass"),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 4b. Sugar Card
                    _buildSugarCard(log.sugar),
                    const SizedBox(height: 25),

                    // 5. Vitamin Section (From Mock 5.png)
                    _buildVitaminSection(log),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
  

  Widget _buildCalorieCard(double consumed, double goal) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Consume today", style: TextStyle(color: Colors.grey[600])),
          Text("${consumed.toInt()}/${goal.toInt()} Cal", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (consumed / goal).clamp(0.0, 1.0),
              backgroundColor: Colors.green.withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation(Colors.green),
              minHeight: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularMacro(String label, double current, double target, Color color, String unit) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: (current / target).clamp(0.0, 1.0),
                strokeWidth: 6,
                backgroundColor: color.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text("${current.toInt()}/$target $unit", style: TextStyle(fontSize: 11, color: Colors.grey[600])),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSugarCard(double sugar) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Sugar Intake", style: TextStyle(color: Colors.grey[600])),
          Text("${sugar.toInt()}g", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.redAccent)),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (sugar / 50).clamp(0.0, 1.0),
              backgroundColor: Colors.redAccent.withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation(Colors.redAccent),
              minHeight: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitaminSection(DailyLogModel log) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Vitamin Intake", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _vitaminBar("A", log.vitamins['a']!, 0.9, "mg"),
          _vitaminBar("B1", log.vitamins['b1']!, 3, "mg"),
          _vitaminBar("C", log.vitamins['c']!, 90, "mg"),
          _vitaminBar("B2", log.vitamins['b2']!, 1.4, "mg"),
        ],
      ),
    );
  }

  Widget _vitaminBar(String label, double current, double target, String unit) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          SizedBox(width: 40, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: (current / target).clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: Colors.blue.withOpacity(0.1),
                valueColor: const AlwaysStoppedAnimation(Colors.blueAccent),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text("${current.toStringAsFixed(2)}/$target $unit", style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(double goal) {
  return FutureBuilder<List<double>>(
    future: _fs.getCurrentWeekCalories(widget.userId),
    builder: (context, snapshot) {
      final caloriesData = snapshot.data ?? [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
      final maxVal = caloriesData.fold(goal, (p, c) => c > p ? c : p);
      
      // Fixed Mon-Sun labels
      final weekLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
      final todayIndex = DateTime.now().weekday - 1; // 0 for Mon, 2 for Wed

      return Container(
        height: 150,
        margin: const EdgeInsets.symmetric(vertical: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(7, (index) {
            final calories = caloriesData[index];
            final barHeight = (calories / maxVal).clamp(0.05, 1.0) * 100;
            final isToday = index == todayIndex;

            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 30,
                  height: barHeight,
                  decoration: BoxDecoration(
                    // Solid green for today, faded for others
                    color: isToday ? Colors.green : Colors.green.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  weekLabels[index],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    color: isToday ? Colors.black : Colors.grey,
                  ),
                ),
              ],
            );
          }),
        ),
      );
    },
  );
}
}