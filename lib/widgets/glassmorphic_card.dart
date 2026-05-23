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

    // In dark mode: white-tinted glass. In light mode: darker frosted glass
    final Color fillColor = isDark
        ? Colors.white.withValues(alpha: fillOpacity)
        : Colors.white.withValues(alpha: 0.75); // Darker frosted glass for light mode contrast
    final Color borderColor = isDark
        ? Colors.white.withValues(alpha: borderOpacity)
        : Colors.white.withValues(alpha: 0.85);
    final Color shadowColor = isDark
        ? Colors.black.withValues(alpha: 0.05)
        : Colors.black.withValues(alpha: 0.06);

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
                blurRadius: 10,
                spreadRadius: 2,
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
