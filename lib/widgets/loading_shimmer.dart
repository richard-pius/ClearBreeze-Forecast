import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Skeleton loader whose shape mirrors the loaded home screen — greeting +
/// location strip, hero card, detail row, precipitation card, AQI card,
/// hourly forecast, and daily forecast.
class LoadingShimmer extends StatelessWidget {
  const LoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color baseColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);
    final Color highlightColor = isDark
        ? Colors.white.withValues(alpha: 0.18)
        : Colors.black.withValues(alpha: 0.12);
    final Color skeletonColor = isDark ? Colors.white : Colors.black;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Greeting pill.
            _pill(width: 90, height: 12, color: skeletonColor),
            const SizedBox(height: 10),
            // Location name.
            _pill(width: 200, height: 22, color: skeletonColor),
            const SizedBox(height: 8),
            _pill(width: 120, height: 12, color: skeletonColor),
            const SizedBox(height: 24),

            _card(height: 260, color: skeletonColor), // hero
            const SizedBox(height: 16),
            _card(height: 100, color: skeletonColor), // detail row
            const SizedBox(height: 16),
            _card(height: 120, color: skeletonColor), // rain
            const SizedBox(height: 16),
            _card(height: 180, color: skeletonColor), // aqi
            const SizedBox(height: 16),
            _card(height: 170, color: skeletonColor), // hourly
            const SizedBox(height: 16),
            _card(height: 260, color: skeletonColor), // daily
          ],
        ),
      ),
    );
  }

  Widget _pill({
    required double width,
    required double height,
    required Color color,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(height / 2),
      ),
    );
  }

  Widget _card({required double height, required Color color}) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(22),
      ),
    );
  }
}
