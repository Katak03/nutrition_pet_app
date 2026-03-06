import 'package:flutter/material.dart';

class MacroCard extends StatelessWidget {
  final String title;
  final double consumed;
  final double goal;
  final Color color;

  const MacroCard({super.key, required this.title, required this.consumed, required this.goal, required this.color});

  @override
  Widget build(BuildContext context) {
    double progress = (consumed / goal).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 60,
            width: 60,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 8,
              backgroundColor: color.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text("${consumed.toInt()}/${goal.toInt()} ${title == 'Water' ? 'glass' : 'g'}",
              style: TextStyle(fontSize: 10, color: Colors.grey[600])),
        ],
      ),
    );
  }
}