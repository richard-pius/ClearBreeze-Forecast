import 'package:flutter/material.dart';
import '../models/weather_data.dart';
import 'glassmorphic_card.dart';

/// Precipitation probability card.
///
/// MET Norway only ships `probability_of_precipitation` for Nordic regions.
/// Rather than inventing a percentage from the symbol code, we honestly
/// show "not available at this location" when the API omits the reading —
/// so the user can trust the numbers they *do* see.
class RainProbabilityCard extends StatelessWidget {
  final WeatherData weatherData;

  const RainProbabilityCard({super.key, required this.weatherData});

  /// Returns icon + color + description for the given probability tier.
  _PrecipitationVisuals _getVisuals(double probability, bool isDark) {
    if (probability >= 70) {
      return _PrecipitationVisuals(
        icon: Icons.water_drop_rounded,
        iconColor: isDark ? Colors.blue.shade200 : Colors.blue.shade700,
        percentColor: isDark ? Colors.blue.shade200 : Colors.blue.shade700,
        description: 'Precipitation very likely',
        gradientColors: [Colors.blue.shade400, Colors.lightBlue.shade200],
      );
    }
    if (probability >= 40) {
      return _PrecipitationVisuals(
        icon: Icons.water_drop_outlined,
        iconColor: isDark ? Colors.lightBlue.shade200 : Colors.blue.shade600,
        percentColor: isDark ? Colors.lightBlue.shade200 : Colors.blue.shade600,
        description: 'Precipitation likely',
        gradientColors: [Colors.lightBlue, Colors.cyan],
      );
    }
    if (probability >= 15) {
      return _PrecipitationVisuals(
        icon: Icons.cloud_queue_rounded,
        iconColor: isDark ? Colors.blueGrey.shade200 : Colors.blueGrey.shade600,
        percentColor: isDark
            ? Colors.blueGrey.shade200
            : Colors.blueGrey.shade600,
        description: 'Slight chance of precipitation',
        gradientColors: [Colors.blueGrey, Colors.lightBlue.shade300],
      );
    }
    if (probability > 0) {
      return _PrecipitationVisuals(
        icon: Icons.cloud_outlined,
        iconColor: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
        percentColor: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
        description: 'Mostly dry conditions',
        gradientColors: [Colors.grey, Colors.blueGrey.shade300],
      );
    }
    return _PrecipitationVisuals(
      icon: Icons.wb_sunny_rounded,
      iconColor: isDark ? Colors.amber.shade300 : Colors.amber.shade800,
      percentColor: isDark ? Colors.amber.shade300 : Colors.amber.shade800,
      description: 'No precipitation expected',
      gradientColors: [Colors.amber, Colors.orangeAccent],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final double? probability = weatherData.precipitationProbability;
    final double? amount = weatherData.precipitation;

    final Color primaryText = isDark ? Colors.white : const Color(0xFF0F172A);
    final Color mutedText = isDark
        ? Colors.white.withValues(alpha: 0.55)
        : const Color(0xFF64748B);

    // No probability from the API — say so plainly.
    if (probability == null) {
      return _NotAvailableCard(
        title: 'Rain Probability',
        message: 'Precipitation probability is not reported at this location.',
        subMessage:
            'MET Norway only publishes probability values for the Nordic region. '
            '${amount != null ? 'Expected amount: ${amount.toStringAsFixed(1)} mm in the next hour.' : ''}',
        primaryText: primaryText,
        mutedText: mutedText,
      );
    }

    final _PrecipitationVisuals visuals = _getVisuals(probability, isDark);
    final Color trackColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.08);

    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rain Probability',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 18,
                  color: primaryText,
                ),
              ),
              Icon(visuals.icon, color: visuals.iconColor),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Text(
                '${probability.round()}%',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: visuals.percentColor,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      visuals.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: primaryText,
                      ),
                    ),
                    if (amount != null && amount > 0)
                      Text(
                        'Expected amount: ${amount.toStringAsFixed(1)} mm',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: mutedText),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          // Progress bar showing the probability visually.
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: 8,
              width: double.infinity,
              color: trackColor,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: probability / 100.0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: visuals.gradientColors),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotAvailableCard extends StatelessWidget {
  final String title;
  final String message;
  final String subMessage;
  final Color primaryText;
  final Color mutedText;

  const _NotAvailableCard({
    required this.title,
    required this.message,
    required this.subMessage,
    required this.primaryText,
    required this.mutedText,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: primaryText,
                ),
              ),
              Icon(Icons.info_outline_rounded, color: mutedText),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.cloud_off_rounded, color: mutedText, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: primaryText,
                        height: 1.35,
                      ),
                    ),
                    if (subMessage.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subMessage.trim(),
                        style: TextStyle(
                          fontSize: 12,
                          color: mutedText,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Internal helper class for precipitation visuals.
class _PrecipitationVisuals {
  final IconData icon;
  final Color iconColor;
  final Color percentColor;
  final String description;
  final List<Color> gradientColors;

  const _PrecipitationVisuals({
    required this.icon,
    required this.iconColor,
    required this.percentColor,
    required this.description,
    required this.gradientColors,
  });
}
