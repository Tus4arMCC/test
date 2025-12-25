import 'package:flutter/material.dart';

class ScheduledSkeleton extends StatefulWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final Color? color;

  const ScheduledSkeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8,
    this.color,
  });

  @override
  State<ScheduledSkeleton> createState() => _ScheduledSkeletonState();
}

class _ScheduledSkeletonState extends State<ScheduledSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
       vsync: this,
       duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _colorAnimation = ColorTween(
      begin: Colors.grey[300],
      end: Colors.grey[100],
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check theme for dark mode adjustments if needed, 
    // but for now relying on hardcoded greys or passed color.
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final baseColor = widget.color ?? (isDark ? Colors.grey[800] : Colors.grey[300]);
    final highlightColor = isDark ? Colors.grey[700] : Colors.grey[100];

    // Re-setup tween if needed based on theme? 
    // For simplicity keeping it dynamic via builder or just simple opacity pulse.
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Color.lerp(baseColor, highlightColor, _controller.value),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        );
      },
    );
  }
}
