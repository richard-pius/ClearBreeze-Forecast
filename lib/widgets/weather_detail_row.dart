import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../models/weather_data.dart';
import 'glassmorphic_card.dart';

class WeatherDetailRow extends StatelessWidget {
  final WeatherData weatherData;

  const WeatherDetailRow({
    super.key,
    required this.weatherData,
  });

  /// Converts wind degree to cardinal direction
  String _getWindDirectionString(double degree) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final int index = (((degree + 22.5) % 360) / 45).floor() % 8;
    return directions[index];
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final String windDir = _getWindDirectionString(weatherData.windDirection);
    final String windStr = '${weatherData.windSpeed.toStringAsFixed(1)} m/s';
    final String humidityStr = '${weatherData.humidity.round()}%';
    final String pressureStr = '${weatherData.pressure.round()} hPa';

    final Color labelColor = isDark
        ? const Color(0xB3FFFFFF)
        : const Color(0xFF475569);
    final Color valueColor =
        isDark ? Colors.white : const Color(0xFF0F172A);
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
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(Color color) {
    return Container(
      height: 40,
      width: 1,
      color: color,
    );
  }

  Widget _buildDetailItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    required Color labelColor,
    required Color valueColor,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 24),
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
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: valueColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  /// Wind gets a rotated arrow reflecting the true wind direction — the arrow
  /// points *in the direction the wind is blowing*.
  Widget _buildWindItem(
    BuildContext context, {
    required String speed,
    required String direction,
    required double degrees,
    required Color labelColor,
    required Color valueColor,
  }) {
    return Expanded(
      child: Column(
        children: [
          Transform.rotate(
            angle: degrees * math.pi / 180,
            child: const Icon(
              Icons.navigation_rounded,
              color: Color(0xFF60A5FA),
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Wind · $direction',
            style: TextStyle(
              fontSize: 12,
              color: labelColor,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            speed,
            style: TextStyle(
              fontSize: 14,
              color: valueColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
