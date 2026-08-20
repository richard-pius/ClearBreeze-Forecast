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
    // Watch so unit toggles refresh the row temperatures.
    final weatherProvider = context.watch<WeatherProvider>();
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color primaryTextColor =
        isDark ? Colors.white : const Color(0xFF0F172A);
    final Color secondaryTextColor =
        isDark ? Colors.white60 : const Color(0xFF64748B);
    final Color highlightBg = isDark
        ? Colors.white.withValues(alpha: 0.09)
        : Colors.white.withValues(alpha: 0.55);
    final Color highlightBorder = isDark
        ? Colors.white.withValues(alpha: 0.18)
        : Colors.white.withValues(alpha: 0.9);
    final Color rainColor =
        isDark ? Colors.lightBlueAccent : Colors.blue.shade700;

    return GlassmorphicCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Icon(Icons.access_time_rounded,
                    size: 20, color: secondaryTextColor),
                const SizedBox(width: 8),
                Text(
                  'Hourly Forecast',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: primaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 130,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              // ListView.builder + itemExtent lets Flutter avoid per-frame
              // layout on the child list — meaningful on lower-end devices
              // with 24-48 hour lists.
              itemExtent: 68,
              itemCount: hourlyForecasts.length,
              itemBuilder: (context, index) {
                final HourlyForecast hour = hourlyForecasts[index];
                final bool isNow = index == 0;

                final String timeLabel =
                    isNow ? 'Now' : DateFormatter.formatShortHour(hour.time);
                final String tempStr =
                    '${weatherProvider.formatTemperature(hour.temperature).round()}°';
                final String emoji =
                    WeatherIconMapper.getEmoji(hour.symbolCode);
                // Only forward a badge value when the API actually reported a
                // probability. Passing null hides the badge — we never invent
                // percentages for regions MET Norway doesn't cover.
                final int? prob = hour.precipitationProbability?.round();

                return _HourCell(
                  timeLabel: timeLabel,
                  emoji: emoji,
                  tempStr: tempStr,
                  probability: prob,
                  isNow: isNow,
                  primaryColor: primaryTextColor,
                  secondaryColor: secondaryTextColor,
                  highlightBg: highlightBg,
                  highlightBorder: highlightBorder,
                  rainColor: rainColor,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HourCell extends StatelessWidget {
  final String timeLabel;
  final String emoji;
  final String tempStr;
  // Null when the API didn't report a precipitation probability for this
  // hour — the badge is simply hidden rather than showing a fake number.
  final int? probability;
  final bool isNow;
  final Color primaryColor;
  final Color secondaryColor;
  final Color highlightBg;
  final Color highlightBorder;
  final Color rainColor;

  const _HourCell({
    required this.timeLabel,
    required this.emoji,
    required this.tempStr,
    required this.probability,
    required this.isNow,
    required this.primaryColor,
    required this.secondaryColor,
    required this.highlightBg,
    required this.highlightBorder,
    required this.rainColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool showProb = probability != null && probability! >= 15;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
      decoration: BoxDecoration(
        color: isNow ? highlightBg : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border:
            isNow ? Border.all(color: highlightBorder, width: 1) : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            timeLabel,
            style: TextStyle(
              fontSize: 12,
              color: isNow ? primaryColor : secondaryColor,
              fontWeight: isNow ? FontWeight.w700 : FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(emoji, style: const TextStyle(fontSize: 26)),
          const SizedBox(height: 8),
          Text(
            tempStr,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          // Reserve constant height whether or not we show the badge, so all
          // cells align vertically.
          SizedBox(
            height: 14,
            child: showProb
                ? Row(
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
                  )
                : null,
          ),
        ],
      ),
    );
  }
}
