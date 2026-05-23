import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/weather_data.dart';
import '../providers/weather_provider.dart';
import '../utils/date_formatter.dart';
import '../utils/weather_icon_mapper.dart';
import 'glassmorphic_card.dart';

class CurrentWeatherCard extends StatelessWidget {
  final WeatherData weatherData;

  const CurrentWeatherCard({
    super.key,
    required this.weatherData,
  });

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final String tempStr = '${weatherProvider.formatTemperature(weatherData.temperature).round()}°';
    final String feelsLikeStr = '${weatherProvider.formatTemperature(weatherData.feelsLike).round()}°';
    final String emoji = WeatherIconMapper.getEmoji(weatherData.symbolCode);

    final Color secondaryColor = isDark
        ? Colors.white.withValues(alpha: 0.7)
        : const Color(0xFF475569); // Slate 600
    final Color tertiaryColor = isDark
        ? Colors.white.withValues(alpha: 0.6)
        : const Color(0xFF64748B); // Slate 500

    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 76),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tempStr,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          height: 1.1,
                        ),
                  ),
                  Text(
                    'Feels like $feelsLikeStr',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: secondaryColor,
                        ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            weatherData.conditionText,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            DateFormatter.formatFullDate(weatherData.time),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: tertiaryColor,
                ),
          ),
        ],
      ),
    );
  }
}
