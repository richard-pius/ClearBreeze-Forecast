import 'dart:ui';
import 'package:flutter/material.dart';

class GlassmorphicCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final double borderOpacity;
  final double fillOpacity;
  final EdgeInsetsGeometry padding;

  const GlassmorphicCard({
    super.key,
    required this.child,
    this.borderRadius = 20.0,
    this.blur = 15.0,
    this.borderOpacity = 0.15,
    this.fillOpacity = 0.08,
    this.padding = const EdgeInsets.all(20.0),
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Dark mode: subtle white-tinted glass with gentle blur
    // Light mode: frosted white glass with stronger opacity for readability
    final Color fillColor = isDark
        ? Colors.white.withValues(alpha: fillOpacity)
        : Colors.white.withValues(alpha: 0.72);
    final Color borderColor = isDark
        ? Colors.white.withValues(alpha: borderOpacity)
        : Colors.white.withValues(alpha: 0.80);
    final Color shadowColor = isDark
        ? Colors.black.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.05);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: borderColor,
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 12,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
