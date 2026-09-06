import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Animated 3-dot "typing..." indicator shown while the bot is composing
/// a response. Each dot bounces in a staggered sequence driven by a single
/// [AnimationController].
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) => _buildDot(index)),
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    // Each dot's animation is offset in time so they bounce in sequence.
    final start = index * 0.2;
    final end = start + 0.4;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final curved = CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeInOut),
        );
        final t = curved.value;
        // Bounce up and back down using a triangular wave over the interval.
        final bounce = t < 0.5 ? t * 2 : (1 - t) * 2;
        final dy = -6.0 * bounce;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: Transform.translate(
            offset: Offset(0, dy),
            child: Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(
                  alpha: 0.5 + (bounce * 0.5),
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }
}
