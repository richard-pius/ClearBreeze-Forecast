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
    final String windStr = '${weatherData.windSpeed.toStringAsFixed(1)} m/s $windDir';
    final String humidityStr = '${weatherData.humidity.round()}%';
    final String pressureStr = '${weatherData.pressure.round()} hPa';

    final Color labelColor = isDark
        ? const Color(0x80FFFFFF)
        : const Color(0xFF475569); // Slate 600
    final Color valueColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final Color dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.black.withValues(alpha: 0.1);

    return GlassmorphicCard(
      padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildDetailItem(
            context,
            Icons.air_rounded,
            'Wind',
            windStr,
            Colors.blueAccent,
            labelColor,
            valueColor,
          ),
          _buildDivider(dividerColor),
          _buildDetailItem(
            context,
            Icons.water_drop_rounded,
            'Humidity',
            humidityStr,
            Colors.lightBlueAccent,
            labelColor,
            valueColor,
          ),
          _buildDivider(dividerColor),
          _buildDetailItem(
            context,
            Icons.speed_rounded,
            'Pressure',
            pressureStr,
            Colors.blueGrey,
            labelColor,
            valueColor,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(Color color) {
    return Container(
      height: 35,
      width: 1,
      color: color,
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color iconColor,
    Color labelColor,
    Color valueColor,
  ) {
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
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: valueColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
