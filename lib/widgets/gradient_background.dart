import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

/// Determines the period of day for gradient selection.
enum DayPeriod {
  night,     // 8 PM - 5 AM
  dawn,      // 5 AM - 7 AM
  morning,   // 7 AM - 11 AM
  afternoon, // 11 AM - 4 PM
  golden,    // 4 PM - 6:30 PM
  dusk,      // 6:30 PM - 8 PM
}

class GradientBackground extends StatelessWidget {
  final String symbolCode;
  final Widget child;

  const GradientBackground({
    super.key,
    required this.symbolCode,
    required this.child,
  });

  /// Returns the current period of day based on local time.
  static DayPeriod getDayPeriod([DateTime? time]) {
    final DateTime now = time ?? DateTime.now();
    final double hour = now.hour + now.minute / 60.0;

    if (hour >= 20.0 || hour < 5.0) return DayPeriod.night;
    if (hour < 7.0) return DayPeriod.dawn;
    if (hour < 11.0) return DayPeriod.morning;
    if (hour < 16.0) return DayPeriod.afternoon;
    if (hour < 18.5) return DayPeriod.golden;
    return DayPeriod.dusk;
  }

  /// Gets gradient colors for DARK theme based on time-of-day and weather.
  static List<Color> _getDarkGradient(DayPeriod period, String symbolCode) {
    final String code = symbolCode.toLowerCase();
    final bool isRainy = code.contains('rain') || code.contains('thunder') || code.contains('sleet');
    final bool isSnowy = code.contains('snow');
    final bool isCloudy = code.contains('cloudy') || code.contains('partlycloudy');
    final bool isFoggy = code.contains('fog');

    // Rainy/stormy weather overrides time-of-day with moody atmosphere
    if (isRainy) {
      switch (period) {
        case DayPeriod.night:
          return const [Color(0xFF0A0F1A), Color(0xFF1A2332)];
        case DayPeriod.dawn:
        case DayPeriod.dusk:
          return const [Color(0xFF1A1F2E), Color(0xFF2A3441)];
        default:
          return const [Color(0xFF1E2A3A), Color(0xFF2D3F52)];
      }
    }

    if (isSnowy) {
      switch (period) {
        case DayPeriod.night:
          return const [Color(0xFF141B28), Color(0xFF253345)];
        case DayPeriod.dawn:
        case DayPeriod.dusk:
          return const [Color(0xFF2A3545), Color(0xFF3D4F62)];
        default:
          return const [Color(0xFF344A60), Color(0xFF4A6178)];
      }
    }

    if (isFoggy) {
      return const [Color(0xFF1F2937), Color(0xFF374151)];
    }

    // Time-of-day based gradients for clear/fair/cloudy weather
    switch (period) {
      case DayPeriod.night:
        return const [
          Color(0xFF050B18), // Very deep navy
          Color(0xFF0D1B33), // Dark navy blue
        ];

      case DayPeriod.dawn:
        return const [
          Color(0xFF1A0E2E), // Deep purple-navy
          Color(0xFF2A1B4A), // Rich twilight purple
          Color(0xFF1E3A5F), // Dawn blue
        ];

      case DayPeriod.morning:
        if (isCloudy) {
          return const [Color(0xFF1C2B3A), Color(0xFF2A3F52)];
        }
        return const [
          Color(0xFF0F2B52), // Rich morning blue
          Color(0xFF1A5276), // Medium blue
        ];

      case DayPeriod.afternoon:
        if (isCloudy) {
          return const [Color(0xFF1F2937), Color(0xFF374151)];
        }
        return const [
          Color(0xFF0E2A4F), // Deep sky
          Color(0xFF1565A8), // Bright blue
        ];

      case DayPeriod.golden:
        if (isCloudy) {
          return const [Color(0xFF1F2530), Color(0xFF2A2F3A)];
        }
        return const [
          Color(0xFF1A1230), // Purple-navy
          Color(0xFF3A1830), // Warm maroon tint
          Color(0xFF4A2818), // Deep golden brown
        ];

      case DayPeriod.dusk:
        return const [
          Color(0xFF120B20), // Deep twilight
          Color(0xFF2A1535), // Twilight purple
          Color(0xFF1A2035), // Dark blue-purple
        ];
    }
  }

  /// Gets gradient colors for LIGHT theme based on time-of-day and weather.
  static List<Color> _getLightGradient(DayPeriod period, String symbolCode) {
    final String code = symbolCode.toLowerCase();
    final bool isRainy = code.contains('rain') || code.contains('thunder') || code.contains('sleet');
    final bool isSnowy = code.contains('snow');
    final bool isCloudy = code.contains('cloudy') || code.contains('partlycloudy');
    final bool isFoggy = code.contains('fog');

    // Rainy weather — cool, muted palette that's still readable
    if (isRainy) {
      switch (period) {
        case DayPeriod.night:
          return const [Color(0xFF3D5A80), Color(0xFF5A7DA8)];
        case DayPeriod.dawn:
        case DayPeriod.dusk:
          return const [Color(0xFF6B8EAD), Color(0xFF8DAFC8)];
        default:
          return const [Color(0xFF7A9BB5), Color(0xFF9BB8CE)];
      }
    }

    if (isSnowy) {
      return const [Color(0xFFB0C4D8), Color(0xFFCBDAE8)];
    }

    if (isFoggy) {
      return const [Color(0xFFC5CCD6), Color(0xFFDBE1E8)];
    }

    // Time-of-day based gradients (soft pastels, eye-friendly)
    switch (period) {
      case DayPeriod.night:
        return const [
          Color(0xFF2C3E6B), // Soft dark blue
          Color(0xFF3D5A8A), // Medium navy
        ];

      case DayPeriod.dawn:
        return const [
          Color(0xFFD4B8E0), // Soft lavender
          Color(0xFFF0C9A6), // Warm peach
          Color(0xFFAED4E8), // Light dawn blue
        ];

      case DayPeriod.morning:
        if (isCloudy) {
          return const [Color(0xFFBCC8D8), Color(0xFFA8B8CA)];
        }
        return const [
          Color(0xFF8EC5E8), // Fresh morning blue
          Color(0xFF68B0DE), // Bright sky blue
        ];

      case DayPeriod.afternoon:
        if (isCloudy) {
          return const [Color(0xFFB8C4D2), Color(0xFFA0AEC0)];
        }
        return const [
          Color(0xFF72B8E8), // Clear sky blue
          Color(0xFF4DA2DB), // Deeper sky
        ];

      case DayPeriod.golden:
        if (isCloudy) {
          return const [Color(0xFFC5B8A8), Color(0xFFB8A898)];
        }
        return const [
          Color(0xFFF0D0A0), // Warm golden
          Color(0xFFE8A878), // Sunset peach
          Color(0xFFD4A0B0), // Soft rose
        ];

      case DayPeriod.dusk:
        return const [
          Color(0xFFC0A0C8), // Twilight lavender
          Color(0xFF8878A8), // Dusky purple
          Color(0xFF5A6890), // Evening blue
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final DayPeriod period = getDayPeriod();
    final List<Color> colors = isDark
        ? _getDarkGradient(period, symbolCode)
        : _getLightGradient(period, symbolCode);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ),
      ),
      child: child,
    );
  }
}
