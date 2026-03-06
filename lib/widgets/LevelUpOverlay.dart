import 'package:flutter/material.dart';
import 'dart:math' as math;

/// MANAGER: Handles showing/hiding the overlay globally
class LevelUpManager {
  static OverlayEntry? _overlayEntry;

  static void show(BuildContext context, {required int oldLevel, required int newLevel}) {
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => LevelUpOverlay(
        oldLevel: oldLevel,
        newLevel: newLevel,
        onDismiss: hide,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);

    Future.delayed(const Duration(seconds: 3), () {
      hide();
    });
  }

  static void hide() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }
}

/// WIDGET: The actual UI popup
class LevelUpOverlay extends StatefulWidget {
  final int oldLevel;
  final int newLevel;
  final VoidCallback onDismiss;

  const LevelUpOverlay({
    Key? key,
    required this.oldLevel,
    required this.newLevel,
    required this.onDismiss,
  }) : super(key: key);

  @override
  State<LevelUpOverlay> createState() => _LevelUpOverlayState();
}

class _LevelUpOverlayState extends State<LevelUpOverlay> with TickerProviderStateMixin {
  late AnimationController _appearController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();

    _appearController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _appearController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _appearController, curve: Curves.easeIn),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _appearController.forward();
  }

  @override
  void dispose() {
    _appearController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        alignment: Alignment.center,
        children: [
          GestureDetector(
            onTap: widget.onDismiss,
            child: Container(color: Colors.black.withOpacity(0.6)),
          ),
          AnimatedBuilder(
            animation: _appearController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: child,
                ),
              );
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _glowController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _glowController.value * 2 * math.pi,
                      child: Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: SweepGradient(
                            colors: [
                              Colors.amber.withOpacity(0.0),
                              Colors.amber.withOpacity(0.5),
                              Colors.amber.withOpacity(0.0),
                              Colors.orange.withOpacity(0.5),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Container(
                  width: 300,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2B2D42), Color(0xFF1A1A2E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                    border: Border.all(color: Colors.amber, width: 2),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "LEVEL UP!",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildLevelBadge(widget.oldLevel, Colors.grey.shade400),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 32),
                          ),
                          _buildLevelBadge(widget.newLevel, Colors.amber),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "Your pet is growing stronger!",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelBadge(int level, Color color) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        level.toString(),
        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}