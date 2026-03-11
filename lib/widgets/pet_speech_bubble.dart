import 'package:flutter/material.dart';

/// Animated speech bubble widget that appears above the pet and fades out
class PetSpeechBubble extends StatefulWidget {
  final String message;
  final Duration displayDuration;
  final VoidCallback? onDismiss;

  const PetSpeechBubble({
    super.key,
    required this.message,
    this.displayDuration = const Duration(seconds: 4),
    this.onDismiss,
  });

  @override
  State<PetSpeechBubble> createState() => _PetSpeechBubbleState();
}

class _PetSpeechBubbleState extends State<PetSpeechBubble> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      reverseDuration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Fade animation: fade in, stay visible, then fade out
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Slide animation: slide up slightly as it appears
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    // Start the animation
    _startBubbleAnimation();
  }

  void _startBubbleAnimation() async {
    if (!mounted) return;
    
    // Fade in + slide in
    await _animationController.forward();

    if (!mounted) return;
    
    // Wait before starting fade out
    await Future.delayed(widget.displayDuration - const Duration(milliseconds: 400));

    if (!mounted) return;
    
    // Fade out + slide out
    await _animationController.reverse();

    if (!mounted) return;
    
    // Dismiss callback
    widget.onDismiss?.call();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Message text
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  widget.message,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Tail pointing down to pet
              Positioned(
                bottom: -8,
                left: 20,
                child: CustomPaint(
                  painter: _BubbleTailPainter(),
                  size: const Size(16, 10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter for the speech bubble tail
class _BubbleTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw triangle tail pointing down
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Wrapper widget that shows the speech bubble in a stack with other widgets
class PetScreenWithBubble extends StatefulWidget {
  final Widget petWidget;
  final String? bubbleMessage;
  final VoidCallback? onBubbleDismiss;

  const PetScreenWithBubble({
    super.key,
    required this.petWidget,
    this.bubbleMessage,
    this.onBubbleDismiss,
  });

  @override
  State<PetScreenWithBubble> createState() => _PetScreenWithBubbleState();
}

class _PetScreenWithBubbleState extends State<PetScreenWithBubble> {
  bool _showBubble = true;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        widget.petWidget,
        if (widget.bubbleMessage != null && _showBubble)
          Positioned(
            top: -60,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.topCenter,
              child: PetSpeechBubble(
                message: widget.bubbleMessage!,
                onDismiss: () {
                  setState(() => _showBubble = false);
                  widget.onBubbleDismiss?.call();
                },
              ),
            ),
          ),
      ],
    );
  }
}
