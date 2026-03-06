import 'package:flutter/material.dart';

class VitaminProgressBar extends StatelessWidget {
  final String label;
  final double current;
  final double target;
  final String unit;

  const VitaminProgressBar({super.key, required this.label, required this.current, required this.target, required this.unit});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(width: 40, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: (current / target).clamp(0.0, 1.0),
                minHeight: 12,
                backgroundColor: Colors.blue.withOpacity(0.1),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text("${current.toStringAsFixed(1)}/$target $unit", style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}