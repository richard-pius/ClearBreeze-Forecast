import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

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
          children: [
            const SizedBox(height: 20),
            // Location Header Skeleton
            Container(
              height: 28,
              width: 180,
              decoration: BoxDecoration(
                color: skeletonColor,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 14,
              width: 100,
              decoration: BoxDecoration(
                color: skeletonColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 35),
            
            // Hero Current Weather Skeleton
            _buildCardSkeleton(height: 180, color: skeletonColor),
            const SizedBox(height: 20),

            // Detail Grid Skeleton
            _buildCardSkeleton(height: 90, color: skeletonColor),
            const SizedBox(height: 20),

            // AQI Card Skeleton
            _buildCardSkeleton(height: 160, color: skeletonColor),
            const SizedBox(height: 20),

            // Hourly Forecast Skeleton
            _buildCardSkeleton(height: 150, color: skeletonColor),
          ],
        ),
      ),
    );
  }

  Widget _buildCardSkeleton({required double height, required Color color}) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
