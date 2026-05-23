import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/weather_data.dart';
import '../providers/weather_provider.dart';
import '../utils/date_formatter.dart';
import '../utils/weather_icon_mapper.dart';
import 'glassmorphic_card.dart';

class HourlyForecastList extends StatelessWidget {
  final List<HourlyForecast> hourlyForecasts;

  const HourlyForecastList({
    super.key,
    required this.hourlyForecasts,
  });

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color primaryTextColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final Color secondaryTextColor = isDark ? Colors.white60 : const Color(0xFF64748B);
    final Color highlightBg = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.white.withValues(alpha: 0.3);
    final Color rainColor = isDark ? Colors.lightBlueAccent : Colors.blue[700]!;

    return GlassmorphicCard(
      padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Text(
              'Hourly Forecast',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: primaryTextColor,
              ),
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: hourlyForecasts.length,
              itemBuilder: (context, index) {
                final HourlyForecast hour = hourlyForecasts[index];
                
                // First item is labeled 'Now' instead of the hour name
                final String timeLabel = index == 0 
                    ? 'Now' 
                    : DateFormatter.formatShortHour(hour.time);
                
                final String tempStr = '${weatherProvider.formatTemperature(hour.temperature).round()}°';
                final String emoji = WeatherIconMapper.getEmoji(hour.symbolCode);
                final int prob = hour.precipitationProbability.round();

                return Container(
                  width: 70,
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    color: index == 0 ? highlightBg : Colors.transparent,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        timeLabel,
                        style: TextStyle(
                          fontSize: 12,
                          color: index == 0 ? primaryTextColor : secondaryTextColor,
                          fontWeight: index == 0 ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        emoji,
                        style: const TextStyle(fontSize: 26),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        tempStr,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: index == 0 ? FontWeight.bold : FontWeight.w600,
                          color: primaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // If there is a meaningful probability of rain, show it
                      if (prob >= 15)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.water_drop_rounded,
                              size: 10,
                              color: rainColor,
                            ),
                            Text(
                              '$prob%',
                              style: TextStyle(
                                fontSize: 9,
                                color: rainColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      else
                        const SizedBox(height: 12), // Placeholder spacing
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
