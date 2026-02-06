import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class ProgressRoad extends StatelessWidget {
  final Color? backgroundColor;
  final Color? progressColor;
  final List<Color>? progressGradient;

  const ProgressRoad({
    super.key,
    this.backgroundColor,
    this.progressColor,
    this.progressGradient,
  });

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final progressVal = userProvider.shortcutProgress;
    // Map index 0-5 to 0.0-1.0 progress
    final progress = progressVal / 5.0; 
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        
        return Container(
          height: 14,
          width: double.infinity,
          clipBehavior: Clip.none, // Allow children to bleed out
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.grey[300],
            borderRadius: BorderRadius.circular(7),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Baseline to force Stack width
              const SizedBox(width: double.infinity, height: 14),

              // 1. Progress Fill
              Align(
                alignment: Alignment.centerLeft,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 1000),
                  width: (width * progress).clamp(0.0, width),
                  height: 14,
                  decoration: BoxDecoration(
                    color: progressGradient == null ? (progressColor ?? Colors.teal[600]) : null,
                    gradient: progressGradient != null 
                        ? LinearGradient(colors: progressGradient!) 
                        : (progressColor == null ? LinearGradient(colors: [Colors.teal[600]!, Colors.teal[400]!]) : null),
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
              ),
              
              // 2. Car emoji
              TweenAnimationBuilder<double>(
                // Remove Key to allow smooth index-to-index animation
                tween: Tween<double>(
                  begin: -1.0, // Still starts from far left on first load
                  end: -1.0 + (2.0 * progress.clamp(0.0, 1.0))
                ),
                duration: const Duration(milliseconds: 2500),
                curve: Curves.easeInOutCubic,
                builder: (context, val, child) {
                  return Align(
                    alignment: Alignment(val, -1.3), // Lowered slightly
                    child: child!,
                  );
                },
                child: Transform.flip(
                  flipX: true, // Face right
                  child: const Icon(
                    Icons.directions_car_rounded,
                    size: 32,
                    color: Colors.redAccent,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
