import 'package:flutter/material.dart';
import '../models/weather_data.dart';
import 'glassmorphic_card.dart';

class RainProbabilityCard extends StatelessWidget {
  final WeatherData weatherData;

  const RainProbabilityCard({
    super.key,
    required this.weatherData,
  });

  /// Returns icon, color, description, and gradient colors based on probability tiers
  _PrecipitationVisuals _getVisuals(double probability, String symbolCode, bool isDark) {
    final String code = symbolCode.toLowerCase();
    
    // Tier 1: Active precipitation (rain/snow/sleet/thunder in symbol)
    if (code.contains('rain') || code.contains('snow') || code.contains('sleet') || code.contains('thunder')) {
      if (code.contains('thunder')) {
        return _PrecipitationVisuals(
          icon: Icons.thunderstorm_rounded,
          iconColor: isDark ? Colors.amber[300]! : Colors.amber[800]!,
          percentColor: isDark ? Colors.amber[300]! : Colors.amber[800]!,
          description: 'Thunderstorm expected',
          gradientColors: [Colors.amber, Colors.deepOrange],
        );
      }
      if (code.contains('heavy')) {
        return _PrecipitationVisuals(
          icon: Icons.water_drop_rounded,
          iconColor: isDark ? Colors.blue[300]! : Colors.blue[800]!,
          percentColor: isDark ? Colors.blue[300]! : Colors.blue[800]!,
          description: 'Heavy precipitation expected',
          gradientColors: [Colors.blue[700]!, Colors.blue[400]!],
        );
      }
      if (code.contains('light')) {
        return _PrecipitationVisuals(
          icon: Icons.water_drop_outlined,
          iconColor: isDark ? Colors.lightBlue[200]! : Colors.blue[600]!,
          percentColor: isDark ? Colors.lightBlue[200]! : Colors.blue[600]!,
          description: 'Light precipitation possible',
          gradientColors: [Colors.lightBlue, Colors.cyan],
        );
      }
      // Regular rain/snow/sleet
      return _PrecipitationVisuals(
        icon: Icons.water_drop_rounded,
        iconColor: isDark ? Colors.blue[200]! : Colors.blue[700]!,
        percentColor: isDark ? Colors.blue[200]! : Colors.blue[700]!,
        description: 'Precipitation expected',
        gradientColors: [Colors.blueAccent, Colors.lightBlueAccent],
      );
    }

    // Tier 2: Probability-based for non-precipitation symbols
    if (probability >= 50) {
      return _PrecipitationVisuals(
        icon: Icons.water_drop_outlined,
        iconColor: isDark ? Colors.blue[200]! : Colors.blue[700]!,
        percentColor: isDark ? Colors.blue[200]! : Colors.blue[700]!,
        description: 'Precipitation likely',
        gradientColors: [Colors.blueAccent, Colors.lightBlueAccent],
      );
    }
    if (probability >= 20) {
      return _PrecipitationVisuals(
        icon: Icons.cloud_queue_rounded,
        iconColor: isDark ? Colors.blueGrey[200]! : Colors.blueGrey[600]!,
        percentColor: isDark ? Colors.blueGrey[200]! : Colors.blueGrey[600]!,
        description: 'Slight chance of precipitation',
        gradientColors: [Colors.blueGrey, Colors.lightBlue[300]!],
      );
    }
    if (probability > 0) {
      return _PrecipitationVisuals(
        icon: Icons.cloud_outlined,
        iconColor: isDark ? Colors.grey[300]! : Colors.grey[600]!,
        percentColor: isDark ? Colors.grey[300]! : Colors.grey[600]!,
        description: 'Mostly dry conditions',
        gradientColors: [Colors.grey, Colors.blueGrey[300]!],
      );
    }
    
    // Tier 3: Clear / sunny
    return _PrecipitationVisuals(
      icon: Icons.wb_sunny_rounded,
      iconColor: isDark ? Colors.amber[300]! : Colors.amber[800]!,
      percentColor: isDark ? Colors.amber[300]! : Colors.amber[800]!,
      description: 'Clear skies expected',
      gradientColors: [Colors.amber, Colors.orangeAccent],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final double probability = weatherData.precipitationProbability;
    final double amount = weatherData.precipitation;
    final visuals = _getVisuals(probability, weatherData.symbolCode, isDark);

    final Color tertiaryColor = isDark
        ? Colors.white.withValues(alpha: 0.6)
        : const Color(0xFF64748B); // Slate 500
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
                    ),
              ),
              Icon(
                visuals.icon,
                color: visuals.iconColor,
              ),
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
                          ),
                    ),
                    if (amount > 0)
                      Text(
                        'Expected amount: ${amount.toStringAsFixed(1)} mm',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: tertiaryColor,
                            ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          // Progress bar / visual indicator
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
                    gradient: LinearGradient(
                      colors: visuals.gradientColors,
                    ),
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

/// Internal helper class for precipitation visuals
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
