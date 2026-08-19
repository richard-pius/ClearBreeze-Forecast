import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/weather_data.dart';
import '../providers/weather_provider.dart';
import '../utils/date_formatter.dart';
import '../utils/weather_icon_mapper.dart';
import 'glassmorphic_card.dart';

/// A 7-day forecast list card. Each row shows the day name, weather emoji,
/// precipitation probability, and a visual range bar between the min and max
/// temperature, scaled against the whole week's min / max so that the bars
/// read as a comparable temperature spread across days.
class DailyForecastList extends StatelessWidget {
  final List<DailyForecast> dailyForecasts;

  const DailyForecastList({
    super.key,
    required this.dailyForecasts,
  });

  @override
  Widget build(BuildContext context) {
    if (dailyForecasts.isEmpty) return const SizedBox.shrink();

    final weatherProvider = context.watch<WeatherProvider>();
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color primaryColor =
        isDark ? Colors.white : const Color(0xFF0F172A);
    final Color secondaryColor = isDark
        ? Colors.white.withValues(alpha: 0.65)
        : const Color(0xFF475569);
    final Color trackColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);
    final Color rainColor =
        isDark ? Colors.lightBlueAccent : Colors.blue.shade700;

    // Compute week min/max for the range bar scale.
    double weekMin = dailyForecasts.first.tempMin;
    double weekMax = dailyForecasts.first.tempMax;
    for (final d in dailyForecasts) {
      if (d.tempMin < weekMin) weekMin = d.tempMin;
      if (d.tempMax > weekMax) weekMax = d.tempMax;
    }
    // Guard against zero-width span (all days identical).
    if ((weekMax - weekMin).abs() < 0.5) {
      weekMax = weekMin + 1;
    }

    // Cap to 7 days.
    final List<DailyForecast> days = dailyForecasts.length > 7
        ? dailyForecasts.sublist(0, 7)
        : dailyForecasts;

    return GlassmorphicCard(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_month_rounded,
                  size: 20, color: secondaryColor),
              const SizedBox(width: 8),
              Text(
                '${days.length}-Day Forecast',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...days.map((day) {
            final double tempMin =
                weatherProvider.formatTemperature(day.tempMin);
            final double tempMax =
                weatherProvider.formatTemperature(day.tempMax);
            final int prob = day.maxPrecipitationProbability.round();
            return _DailyForecastRow(
              dayName: DateFormatter.formatDayName(day.date),
              emoji: WeatherIconMapper.getEmoji(day.symbolCode),
              probability: prob,
              tempMin: tempMin,
              tempMax: tempMax,
              weekMin: weekMin,
              weekMax: weekMax,
              primaryColor: primaryColor,
              secondaryColor: secondaryColor,
              trackColor: trackColor,
              rainColor: rainColor,
            );
          }),
        ],
      ),
    );
  }
}

class _DailyForecastRow extends StatelessWidget {
  final String dayName;
  final String emoji;
  final int probability;
  final double tempMin;
  final double tempMax;
  final double weekMin;
  final double weekMax;
  final Color primaryColor;
  final Color secondaryColor;
  final Color trackColor;
  final Color rainColor;

  const _DailyForecastRow({
    required this.dayName,
    required this.emoji,
    required this.probability,
    required this.tempMin,
    required this.tempMax,
    required this.weekMin,
    required this.weekMax,
    required this.primaryColor,
    required this.secondaryColor,
    required this.trackColor,
    required this.rainColor,
  });

  @override
  Widget build(BuildContext context) {
    // Position [0..1] of this day's min / max on the week's temperature scale.
    final double span = weekMax - weekMin;
    final double startFrac = ((tempMin - weekMin) / span).clamp(0.0, 1.0);
    final double endFrac = ((tempMax - weekMin) / span).clamp(0.0, 1.0);
    final double widthFrac = (endFrac - startFrac).clamp(0.06, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          // Day name — fixed width so bars align across rows.
          SizedBox(
            width: 74,
            child: Text(
              dayName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
          ),
          // Emoji + precipitation stack, small fixed width.
          SizedBox(
            width: 46,
            child: Column(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 22)),
                if (probability >= 15)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.water_drop_rounded,
                            size: 10, color: rainColor),
                        const SizedBox(width: 2),
                        Text(
                          '$probability%',
                          style: TextStyle(
                            fontSize: 10,
                            color: rainColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Min temp label.
          SizedBox(
            width: 34,
            child: Text(
              '${tempMin.round()}°',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: secondaryColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Range bar.
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double totalWidth = constraints.maxWidth;
                final double leftPad = totalWidth * startFrac;
                final double barWidth = totalWidth * widthFrac;
                return SizedBox(
                  height: 6,
                  child: Stack(
                    children: [
                      // Track.
                      Container(
                        decoration: BoxDecoration(
                          color: trackColor,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      // Range fill — cool → warm gradient.
                      Positioned(
                        left: leftPad,
                        width: barWidth,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF60A5FA), // cool blue
                                Color(0xFFFBBF24), // warm amber
                                Color(0xFFF97316), // hot orange
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          // Max temp label.
          SizedBox(
            width: 34,
            child: Text(
              '${tempMax.round()}°',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
