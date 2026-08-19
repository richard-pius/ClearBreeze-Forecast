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
    // We only rebuild on unit / theme changes — read once via listen: false and
    // let the parent Consumer handle unit rebuilds.
    final weatherProvider = context.watch<WeatherProvider>();
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final String tempStr =
        '${weatherProvider.formatTemperature(weatherData.temperature).round()}°';
    final String feelsLikeStr =
        '${weatherProvider.formatTemperature(weatherData.feelsLike).round()}°';
    final String emoji = WeatherIconMapper.getEmoji(weatherData.symbolCode);
    final String conditionText = weatherData.conditionText;

    // Today's high / low from the first daily forecast, if available.
    DailyForecast? today;
    if (weatherData.dailyForecasts.isNotEmpty) {
      today = weatherData.dailyForecasts.first;
    }

    final Color primaryColor =
        isDark ? Colors.white : const Color(0xFF0F172A);
    final Color secondaryColor = isDark
        ? Colors.white.withValues(alpha: 0.72)
        : const Color(0xFF475569);
    final Color tertiaryColor = isDark
        ? Colors.white.withValues(alpha: 0.55)
        : const Color(0xFF64748B);
    final Color chipBg = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.55);
    final Color chipBorder = isDark
        ? Colors.white.withValues(alpha: 0.15)
        : Colors.white.withValues(alpha: 0.85);

    return GlassmorphicCard(
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Weather emoji with a soft radial glow behind it.
          SizedBox(
            height: 96,
            width: 96,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withValues(alpha: isDark ? 0.14 : 0.55),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
                Text(emoji, style: const TextStyle(fontSize: 76)),
              ],
            ),
          ),
          const SizedBox(height: 4),
          // Big temperature — use tabular-ish weight for a premium feel.
          Text(
            tempStr,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 96,
                  fontWeight: FontWeight.w300,
                  height: 1.0,
                  letterSpacing: -3.5,
                  color: primaryColor,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            conditionText,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: primaryColor,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Feels like $feelsLikeStr',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: secondaryColor,
            ),
          ),
          const SizedBox(height: 16),
          // High / low chip row — only shown when the daily aggregate exists.
          if (today != null)
            _HighLowRow(
              tempMax: weatherProvider.formatTemperature(today.tempMax),
              tempMin: weatherProvider.formatTemperature(today.tempMin),
              chipBg: chipBg,
              chipBorder: chipBorder,
              primaryColor: primaryColor,
              secondaryColor: secondaryColor,
            ),
          if (today != null) const SizedBox(height: 12),
          Text(
            DateFormatter.formatFullDate(weatherData.time),
            style: TextStyle(fontSize: 13, color: tertiaryColor),
          ),
        ],
      ),
    );
  }
}

class _HighLowRow extends StatelessWidget {
  final double tempMax;
  final double tempMin;
  final Color chipBg;
  final Color chipBorder;
  final Color primaryColor;
  final Color secondaryColor;

  const _HighLowRow({
    required this.tempMax,
    required this.tempMin,
    required this.chipBg,
    required this.chipBorder,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: chipBg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: chipBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.arrow_upward_rounded,
              size: 15, color: Colors.orange.shade400),
          const SizedBox(width: 4),
          Text(
            '${tempMax.round()}°',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 1,
            height: 12,
            color: secondaryColor.withValues(alpha: 0.35),
          ),
          const SizedBox(width: 12),
          Icon(Icons.arrow_downward_rounded,
              size: 15, color: Colors.lightBlue.shade300),
          const SizedBox(width: 4),
          Text(
            '${tempMin.round()}°',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
