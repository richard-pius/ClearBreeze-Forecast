import 'package:flutter/material.dart';
import '../models/weather_data.dart';
import 'glassmorphic_card.dart';

class RainProbabilityCard extends StatelessWidget {
  final WeatherData weatherData;

  const RainProbabilityCard({
    super.key,
    required this.weatherData,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final double probability = weatherData.precipitationProbability;
    final double amount = weatherData.precipitation;
    final bool isSunny = probability < 20.0;

    final Color tertiaryColor = isDark
        ? Colors.white.withValues(alpha: 0.6)
        : const Color(0xFF64748B); // Slate 500
    final Color trackColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.08);
    final Color percentColor = isDark
        ? (isSunny ? Colors.amber[300]! : Colors.blue[300]!)
        : (isSunny ? Colors.amber[800]! : Colors.blue[700]!);

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
                isSunny ? Icons.wb_sunny_rounded : Icons.water_drop_outlined,
                color: isSunny ? Colors.amber : Colors.lightBlueAccent,
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
                      color: percentColor,
                    ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isSunny ? 'Expect clear/sunny skies' : 'Chance of precipitation',
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
                      colors: isSunny
                          ? [Colors.amber, Colors.orangeAccent]
                          : [Colors.blueAccent, Colors.lightBlueAccent],
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
