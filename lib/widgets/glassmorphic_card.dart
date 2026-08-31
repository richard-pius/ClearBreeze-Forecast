import 'dart:ui';
import 'package:flutter/material.dart';

/// A premium frosted-glass card with a subtle inner gradient sheen and a soft
/// top-edge highlight. Uses [BackdropFilter] for the blur — reuse the widget
/// sparingly on the same screen; each blur node is GPU-expensive.
class GlassmorphicCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final double borderOpacity;
  final double fillOpacity;
  final EdgeInsetsGeometry padding;

  /// Optional accent color that tints the inner gradient sheen. When null the
  /// card uses a neutral white/light sheen matching the current theme.
  final Color? accentColor;

  const GlassmorphicCard({
    super.key,
    required this.child,
    this.borderRadius = 22.0,
    this.blur = 18.0,
    this.borderOpacity = 0.18,
    this.fillOpacity = 0.10,
    this.padding = const EdgeInsets.all(20.0),
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Base surface: subtle glass in dark mode, frosted white in light mode.
    final Color fillTop = isDark
        ? Colors.white.withValues(alpha: fillOpacity + 0.04)
        : Colors.white.withValues(alpha: 0.78);
    final Color fillBottom = isDark
        ? Colors.white.withValues(alpha: fillOpacity - 0.02)
        : Colors.white.withValues(alpha: 0.62);

    final Color borderColor = isDark
        ? Colors.white.withValues(alpha: borderOpacity)
        : Colors.white.withValues(alpha: 0.85);

    final Color shadowColor = isDark
        ? Colors.black.withValues(alpha: 0.28)
        : Colors.black.withValues(alpha: 0.08);

    // Accent sheen — pulled from accentColor if provided; otherwise a soft
    // white/blue tint. Very low opacity so it just adds depth.
    final Color sheenColor =
        accentColor ?? (isDark ? Colors.white : const Color(0xFF60A5FA));

    // RepaintBoundary matters here: BackdropFilter re-samples everything
    // painted beneath it, and the home screen stacks six of these cards over
    // an animated gradient. Isolating each one stops an unrelated repaint
    // (a shimmer tick, the AQI gauge animating) from forcing every other
    // card to re-blur.
    return RepaintBoundary(
      child: DecoratedBox(
        // Soft outer shadow to lift the card off the gradient background.
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 22,
              spreadRadius: -2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                // Vertical gradient gives the surface depth versus a flat fill.
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [fillTop, fillBottom],
                ),
                border: Border.all(color: borderColor, width: 1.0),
              ),
              child: Stack(
                children: [
                  // Sheen highlight — a soft radial glow at the top-left that
                  // reads as light catching the glass.
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(borderRadius),
                          gradient: RadialGradient(
                            center: const Alignment(-0.9, -1.1),
                            radius: 1.4,
                            colors: [
                              sheenColor.withValues(
                                alpha: isDark ? 0.10 : 0.16,
                              ),
                              sheenColor.withValues(alpha: 0.0),
                            ],
                            stops: const [0.0, 0.6],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(padding: padding, child: child),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
