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
    final Color primaryTextColor =
        isDark ? Colors.white : const Color(0xFF0F172A);
    final Color secondaryTextColor =
        isDark ? Colors.white70 : const Color(0xFF475569);
    final Color mutedTextColor =
        isDark ? const Color(0x80FFFFFF) : const Color(0xFF64748B);
    final Color iconMutedColor =
        isDark ? Colors.white70 : const Color(0xFF64748B);
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
                    Icon(Icons.location_off_outlined,
                        size: 40, color: secondaryTextColor),
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

    // Build the list of available pollutants so we only render chips for
    // stations that reported that particular reading.
    final List<_Pollutant> pollutants = _collectPollutants(aqiData);

    return GlassmorphicCard(
      accentColor: color,
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
                              style: Theme.of(context)
                                  .textTheme
                                  .displayMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 34,
                                    height: 1.0,
                                    color: primaryTextColor,
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
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
          // Pollutant chip row — only when at least one reading exists.
          if (pollutants.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: pollutants
                  .map((p) => _PollutantChip(
                        pollutant: p,
                        isDark: isDark,
                        textColor: primaryTextColor,
                        labelColor: mutedTextColor,
                      ))
                  .toList(growable: false),
            ),
          ],
          const SizedBox(height: 12),
          Divider(color: dividerColor, height: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Station: ${aqiData.stationName}',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: mutedTextColor),
                ),
              ),
              if (aqiData.distanceKm != null)
                Text(
                  '${aqiData.distanceKm} km away',
                  style: TextStyle(fontSize: 11, color: mutedTextColor),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Collect only the pollutant readings that are actually present.
  List<_Pollutant> _collectPollutants(AirQualityData d) {
    final List<_Pollutant> list = [];
    if (d.pm25 != null) {
      list.add(_Pollutant('PM2.5', d.pm25!, 'µg/m³'));
    }
    if (d.pm10 != null) {
      list.add(_Pollutant('PM10', d.pm10!, 'µg/m³'));
    }
    if (d.o3 != null) list.add(_Pollutant('O₃', d.o3!, 'µg/m³'));
    if (d.no2 != null) list.add(_Pollutant('NO₂', d.no2!, 'µg/m³'));
    if (d.so2 != null) list.add(_Pollutant('SO₂', d.so2!, 'µg/m³'));
    if (d.co != null) list.add(_Pollutant('CO', d.co!, 'mg/m³'));
    return list;
  }
}

class _Pollutant {
  final String label;
  final double value;
  final String unit;
  const _Pollutant(this.label, this.value, this.unit);
}

class _PollutantChip extends StatelessWidget {
  final _Pollutant pollutant;
  final bool isDark;
  final Color textColor;
  final Color labelColor;

  const _PollutantChip({
    required this.pollutant,
    required this.isDark,
    required this.textColor,
    required this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color chipBg = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.white.withValues(alpha: 0.55);
    final Color chipBorder = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.white.withValues(alpha: 0.85);

    // Render value with sensible precision (integer if it's a whole number).
    final double v = pollutant.value;
    final String valueStr =
        v >= 100 ? v.round().toString() : v.toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: chipBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: chipBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            pollutant.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: labelColor,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            valueStr,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            pollutant.unit,
            style: TextStyle(fontSize: 10, color: labelColor),
          ),
        ],
      ),
    );
  }
}
