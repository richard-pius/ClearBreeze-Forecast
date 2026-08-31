import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../models/weather_data.dart';
import 'glassmorphic_card.dart';

/// Wind / Humidity / Pressure strip. Each cell renders "Not available" when
/// the underlying field is null so a real zero (calm wind, 0 % humidity) is
/// visually distinct from "the API didn't report this at this location".
class WeatherDetailRow extends StatelessWidget {
  final WeatherData weatherData;

  const WeatherDetailRow({super.key, required this.weatherData});

  /// Converts wind degree to cardinal direction. Returns null when the input
  /// itself is null.
  String? _getWindDirectionString(double? degree) {
    if (degree == null) return null;
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final int index = (((degree + 22.5) % 360) / 45).floor() % 8;
    return directions[index];
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final String? windDir = _getWindDirectionString(weatherData.windDirection);
    final String? windStr = weatherData.windSpeed == null
        ? null
        : '${weatherData.windSpeed!.toStringAsFixed(1)} m/s';
    final String? humidityStr = weatherData.humidity == null
        ? null
        : '${weatherData.humidity!.round()}%';
    final String? pressureStr = weatherData.pressure == null
        ? null
        : '${weatherData.pressure!.round()} hPa';

    final Color labelColor = isDark
        ? const Color(0xB3FFFFFF)
        : const Color(0xFF475569);
    final Color valueColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final Color mutedColor = isDark
        ? Colors.white.withValues(alpha: 0.45)
        : const Color(0xFF94A3B8);
    final Color dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.black.withValues(alpha: 0.08);

    return GlassmorphicCard(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildWindItem(
            context,
            speed: windStr,
            direction: windDir,
            degrees: weatherData.windDirection,
            labelColor: labelColor,
            valueColor: valueColor,
            mutedColor: mutedColor,
          ),
          _buildDivider(dividerColor),
          _buildDetailItem(
            context,
            icon: Icons.water_drop_rounded,
            label: 'Humidity',
            value: humidityStr,
            iconColor: const Color(0xFF60A5FA),
            labelColor: labelColor,
            valueColor: valueColor,
            mutedColor: mutedColor,
          ),
          _buildDivider(dividerColor),
          _buildDetailItem(
            context,
            icon: Icons.speed_rounded,
            label: 'Pressure',
            value: pressureStr,
            iconColor: const Color(0xFF94A3B8),
            labelColor: labelColor,
            valueColor: valueColor,
            mutedColor: mutedColor,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(Color color) {
    return Container(height: 40, width: 1, color: color);
  }

  Widget _buildDetailItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String? value,
    required Color iconColor,
    required Color labelColor,
    required Color valueColor,
    required Color mutedColor,
  }) {
    final bool available = value != null;
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: available ? iconColor : iconColor.withValues(alpha: 0.35),
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: labelColor,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 4),
          if (available)
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: valueColor,
                fontWeight: FontWeight.w700,
              ),
            )
          else
            Text(
              'Not available',
              style: TextStyle(
                fontSize: 11,
                color: mutedColor,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  /// Wind cell — rotated arrow if we know the direction, greyed icon +
  /// "Not available" if the station didn't report wind.
  Widget _buildWindItem(
    BuildContext context, {
    required String? speed,
    required String? direction,
    required double? degrees,
    required Color labelColor,
    required Color valueColor,
    required Color mutedColor,
  }) {
    final bool available = speed != null;
    return Expanded(
      child: Column(
        children: [
          Transform.rotate(
            angle: (degrees ?? 0) * math.pi / 180,
            child: Icon(
              Icons.navigation_rounded,
              color: available
                  ? const Color(0xFF60A5FA)
                  : const Color(0xFF60A5FA).withValues(alpha: 0.35),
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            direction == null ? 'Wind' : 'Wind · $direction',
            style: TextStyle(
              fontSize: 12,
              color: labelColor,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 4),
          if (available)
            Text(
              speed,
              style: TextStyle(
                fontSize: 14,
                color: valueColor,
                fontWeight: FontWeight.w700,
              ),
            )
          else
            Text(
              'Not available',
              style: TextStyle(
                fontSize: 11,
                color: mutedColor,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}
