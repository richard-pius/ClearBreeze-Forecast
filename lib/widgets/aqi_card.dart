import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/air_quality_data.dart';
import 'aqi_gauge.dart';
import 'glassmorphic_card.dart';

class AqiCard extends StatelessWidget {
  final AirQualityData aqiData;

  const AqiCard({
    super.key,
    required this.aqiData,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryTextColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final Color secondaryTextColor = isDark ? Colors.white70 : const Color(0xFF475569);
    final Color mutedTextColor = isDark
        ? const Color(0x80FFFFFF)
        : const Color(0xFF64748B); // Slate 500
    final Color iconMutedColor = isDark ? Colors.white70 : const Color(0xFF64748B);
    final Color dividerColor = isDark ? Colors.white10 : Colors.black12;

    if (aqiData.isEmpty || aqiData.aqi == 0) {
      return GlassmorphicCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Air Quality Index',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: primaryTextColor,
                  ),
                ),
                Icon(Icons.air, color: iconMutedColor),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Column(
                  children: [
                    Icon(Icons.location_off_outlined, size: 40, color: secondaryTextColor),
                    const SizedBox(height: 10),
                    Text(
                      'No AQI Monitoring Stations Nearby',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'No station reported PM2.5 or PM10 data within a 25km radius.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    final int aqi = aqiData.aqi;
    final Map<String, dynamic> aqiLevel = AppTheme.getAqiLevel(aqi);
    final String category = aqiLevel['name'];
    final Color color = aqiLevel['color'];
    final String description = aqiLevel['description'];

    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Air Quality Index',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: primaryTextColor,
                ),
              ),
              Icon(Icons.air, color: color),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Circular Gauge
              SizedBox(
                width: 150,
                height: 110,
                child: Center(
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      AqiGauge(aqi: aqi),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 15.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$aqi',
                              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 34,
                                    height: 1.0,
                                  ),
                            ),
                            Text(
                              'AQI',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: mutedTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 15),
              // Level Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: color.withValues(alpha: 0.3),
                          width: 1.0,
                        ),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: secondaryTextColor,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(color: dividerColor),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Station: ${aqiData.stationName}',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: mutedTextColor,
                  ),
                ),
              ),
              if (aqiData.distanceKm != null)
                Text(
                  '${aqiData.distanceKm} km away',
                  style: TextStyle(
                    fontSize: 11,
                    color: mutedTextColor,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
