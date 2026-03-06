import 'package:flutter/material.dart';

class PetStatBar extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const PetStatBar({super.key, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label)),
          Expanded(
            child: LinearProgressIndicator(
              value: value / 100,
              color: color,
              backgroundColor: Colors.grey[300],
              minHeight: 10,
            ),
          ),
          SizedBox(width: 40, child: Text(' $value', textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}