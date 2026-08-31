import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/air_quality_data.dart';
import 'aqi_gauge.dart';
import 'glassmorphic_card.dart';

/// Air Quality Index card.
///
/// Shows a live EPA AQI when OpenAQ reports the PM readings required to
/// compute one. When it does not, the card explains precisely why the data is
/// missing rather than showing a placeholder number — and still surfaces any
/// secondary pollutants the station did report.
class AqiCard extends StatelessWidget {
  final AirQualityData aqiData;

  const AqiCard({super.key, required this.aqiData});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final _Palette palette = _Palette.of(isDark);

    if (!aqiData.hasData) {
      return _UnavailableAqiCard(aqiData: aqiData, palette: palette);
    }

    final int aqi = aqiData.aqi!;
    final Map<String, dynamic> aqiLevel = AppTheme.getAqiLevel(aqi);
    final String category = aqiLevel['name'];
    final Color color = aqiLevel['color'];
    final String description = aqiLevel['description'];

    final List<_Pollutant> pollutants = _collectPollutants(aqiData);

    return GlassmorphicCard(
      accentColor: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            title: 'Air Quality Index',
            icon: Icons.air,
            iconColor: color,
            titleColor: palette.primary,
          ),
          const SizedBox(height: 15),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
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
                              style: Theme.of(context).textTheme.displayMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 34,
                                    height: 1.0,
                                    color: palette.primary,
                                  ),
                            ),
                            Text(
                              'AQI',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: palette.muted,
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
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
                        color: palette.secondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (pollutants.isNotEmpty) ...[
            const SizedBox(height: 14),
            _PollutantWrap(pollutants: pollutants, palette: palette),
          ],
          const SizedBox(height: 12),
          Divider(color: palette.divider, height: 1),
          const SizedBox(height: 10),
          _StationFooter(aqiData: aqiData, palette: palette),
        ],
      ),
    );
  }

  static List<_Pollutant> _collectPollutants(AirQualityData d) {
    return [
      if (d.pm25 != null) _Pollutant('PM2.5', d.pm25!, 'µg/m³'),
      if (d.pm10 != null) _Pollutant('PM10', d.pm10!, 'µg/m³'),
      if (d.o3 != null) _Pollutant('O₃', d.o3!, 'µg/m³'),
      if (d.no2 != null) _Pollutant('NO₂', d.no2!, 'µg/m³'),
      if (d.so2 != null) _Pollutant('SO₂', d.so2!, 'µg/m³'),
      if (d.co != null) _Pollutant('CO', d.co!, 'mg/m³'),
    ];
  }
}

/// The "no data" presentation. Explains the specific reason, and still shows
/// any pollutants the station reported even though they were insufficient to
/// compute an EPA index.
class _UnavailableAqiCard extends StatelessWidget {
  final AirQualityData aqiData;
  final _Palette palette;

  const _UnavailableAqiCard({required this.aqiData, required this.palette});

  IconData _iconFor(AqiUnavailableReason reason) {
    switch (reason) {
      case AqiUnavailableReason.notConfigured:
        return Icons.key_off_rounded;
      case AqiUnavailableReason.noStationNearby:
        return Icons.location_off_outlined;
      case AqiUnavailableReason.noMeasurements:
        return Icons.sensors_off_rounded;
      case AqiUnavailableReason.fetchFailed:
        return Icons.cloud_off_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AqiUnavailableReason reason =
        aqiData.unavailableReason ?? AqiUnavailableReason.fetchFailed;
    final List<_Pollutant> pollutants = AqiCard._collectPollutants(aqiData);

    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            title: 'Air Quality Index',
            icon: Icons.air,
            iconColor: palette.muted,
            titleColor: palette.primary,
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: palette.muted.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _iconFor(reason),
                  size: 24,
                  color: palette.secondary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reason.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: palette.primary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      reason.message,
                      style: TextStyle(
                        color: palette.secondary,
                        fontSize: 12.5,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // A station may report NO2/O3/etc. without PM2.5 or PM10. Those
          // readings are real data, so we show them even though no EPA index
          // could be derived from them.
          if (pollutants.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'REPORTED BY THIS STATION',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
                color: palette.muted,
              ),
            ),
            const SizedBox(height: 8),
            _PollutantWrap(pollutants: pollutants, palette: palette),
          ],
          if (aqiData.stationName != null) ...[
            const SizedBox(height: 14),
            Divider(color: palette.divider, height: 1),
            const SizedBox(height: 10),
            _StationFooter(aqiData: aqiData, palette: palette),
          ],
        ],
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Color titleColor;

  const _CardHeader({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: titleColor,
          ),
        ),
        Icon(icon, color: iconColor),
      ],
    );
  }
}

class _StationFooter extends StatelessWidget {
  final AirQualityData aqiData;
  final _Palette palette;

  const _StationFooter({required this.aqiData, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            'Station: ${aqiData.stationName ?? 'Not available'}',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, color: palette.muted),
          ),
        ),
        if (aqiData.distanceKm != null)
          Text(
            '${aqiData.distanceKm} km away',
            style: TextStyle(fontSize: 11, color: palette.muted),
          ),
      ],
    );
  }
}

class _PollutantWrap extends StatelessWidget {
  final List<_Pollutant> pollutants;
  final _Palette palette;

  const _PollutantWrap({required this.pollutants, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: pollutants
          .map((p) => _PollutantChip(pollutant: p, palette: palette))
          .toList(growable: false),
    );
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
  final _Palette palette;

  const _PollutantChip({required this.pollutant, required this.palette});

  @override
  Widget build(BuildContext context) {
    final double v = pollutant.value;
    final String valueStr = v >= 100
        ? v.round().toString()
        : v.toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: palette.chipBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: palette.chipBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            pollutant.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: palette.muted,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            valueStr,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: palette.primary,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            pollutant.unit,
            style: TextStyle(fontSize: 10, color: palette.muted),
          ),
        ],
      ),
    );
  }
}

/// Theme-aware colors shared across this card's subwidgets.
class _Palette {
  final Color primary;
  final Color secondary;
  final Color muted;
  final Color divider;
  final Color chipBg;
  final Color chipBorder;

  const _Palette({
    required this.primary,
    required this.secondary,
    required this.muted,
    required this.divider,
    required this.chipBg,
    required this.chipBorder,
  });

  factory _Palette.of(bool isDark) {
    return _Palette(
      primary: isDark ? Colors.white : const Color(0xFF0F172A),
      secondary: isDark ? Colors.white70 : const Color(0xFF475569),
      muted: isDark ? const Color(0x80FFFFFF) : const Color(0xFF64748B),
      divider: isDark ? Colors.white10 : Colors.black12,
      chipBg: isDark
          ? Colors.white.withValues(alpha: 0.06)
          : Colors.white.withValues(alpha: 0.55),
      chipBorder: isDark
          ? Colors.white.withValues(alpha: 0.12)
          : Colors.white.withValues(alpha: 0.85),
    );
  }
}
