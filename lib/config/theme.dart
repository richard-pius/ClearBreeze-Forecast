import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand colors
  static const Color primaryDark = Color(0xFF0A1628); // 0x0A1628 (deep navy)
  static const Color primary = Color(0xFF0A1628);
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0x99FFFFFF); // 60% white

  // Light mode text colors
  static const Color textPrimaryLight = Color(0xFF1E293B); // Slate 800
  static const Color textSecondaryLight = Color(0xFF475569); // Slate 600

  // AQI color scale (US EPA Standards, soft harmonized HSL-like colors)
  static const Color aqiGood = Color(0xFF10B981);       // Soft Emerald Green
  static const Color aqiModerate = Color(0xFFF59E0B);   // Soft Amber Yellow
  static const Color aqiUnhealthySensitive = Color(0xFFF97316); // Soft Orange
  static const Color aqiUnhealthy = Color(0xFFEF4444);  // Soft Crimson Red
  static const Color aqiVeryUnhealthy = Color(0xFF8B5CF6); // Soft Purple
  static const Color aqiHazardous = Color(0xFF7F1D1D);     // Deep Maroon

  // Background gradients based on time / weather (Dark Mode)
  static const List<Color> bgNight = [
    Color(0xFF050B14),
    Color(0xFF0F2038),
  ];

  static const List<Color> bgDaySunny = [
    Color(0xFF1E3A8A), // Rich Navy
    Color(0xFF3B82F6), // Bright Blue
  ];

  static const List<Color> bgDayCloudy = [
    Color(0xFF1F2937), // Dark Grey
    Color(0xFF4B5563), // Light Grey
  ];

  static const List<Color> bgSunset = [
    Color(0xFF111827),
    Color(0xFF7C2D12), // Deep Orange/Brown
    Color(0xFFBE123C), // Crimson
  ];

  static const List<Color> bgRainy = [
    Color(0xFF0F172A),
    Color(0xFF334155),
  ];

  // Background gradients (Light Mode — soft pastels)
  static const List<Color> bgNightLight = [
    Color(0xFF1E293B),
    Color(0xFF334155),
  ];

  static const List<Color> bgDaySunnyLight = [
    Color(0xFF7DD3FC), // Sky 300
    Color(0xFF38BDF8), // Sky 400
  ];

  static const List<Color> bgDayCloudyLight = [
    Color(0xFFCBD5E1), // Slate 300
    Color(0xFF94A3B8), // Slate 400
  ];

  static const List<Color> bgSunsetLight = [
    Color(0xFFFBCFE8), // Pink 200
    Color(0xFFFDBA74), // Orange 300
  ];

  static const List<Color> bgRainyLight = [
    Color(0xFF94A3B8), // Slate 400
    Color(0xFF64748B), // Slate 500
  ];

  // Dark Theme definition
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primary,
      scaffoldBackgroundColor: Colors.transparent, // Background will be gradients
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme.copyWith(
              displayLarge: GoogleFonts.outfit(
                fontSize: 64,
                fontWeight: FontWeight.w700,
                color: textPrimary,
                letterSpacing: -1.5,
              ),
              displayMedium: GoogleFonts.outfit(
                fontSize: 36,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
              titleLarge: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
              bodyLarge: const TextStyle(
                fontSize: 16,
                color: textPrimary,
                fontWeight: FontWeight.normal,
              ),
              bodyMedium: const TextStyle(
                fontSize: 14,
                color: textSecondary,
              ),
            ),
      ),
      cardTheme: const CardThemeData(
        color: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
    );
  }

  // Light Theme definition
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: accentBlue,
      scaffoldBackgroundColor: Colors.transparent,
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.light().textTheme.copyWith(
              displayLarge: GoogleFonts.outfit(
                fontSize: 64,
                fontWeight: FontWeight.w700,
                color: textPrimaryLight,
                letterSpacing: -1.5,
              ),
              displayMedium: GoogleFonts.outfit(
                fontSize: 36,
                fontWeight: FontWeight.w600,
                color: textPrimaryLight,
              ),
              titleLarge: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: textPrimaryLight,
              ),
              bodyLarge: const TextStyle(
                fontSize: 16,
                color: textPrimaryLight,
                fontWeight: FontWeight.normal,
              ),
              bodyMedium: const TextStyle(
                fontSize: 14,
                color: textSecondaryLight,
              ),
            ),
      ),
      cardTheme: const CardThemeData(
        color: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
    );
  }

  // Get AQI Color and Category Name
  static Map<String, dynamic> getAqiLevel(int aqi) {
    if (aqi <= 50) {
      return {
        'name': 'Good',
        'color': aqiGood,
        'description': 'Air quality is satisfactory, and air pollution poses little or no risk.',
      };
    } else if (aqi <= 100) {
      return {
        'name': 'Moderate',
        'color': aqiModerate,
        'description': 'Air quality is acceptable. However, there may be a risk for some people, particularly those who are unusually sensitive to air pollution.',
      };
    } else if (aqi <= 150) {
      return {
        'name': 'Unhealthy for Sensitive Groups',
        'color': aqiUnhealthySensitive,
        'description': 'Members of sensitive groups may experience health effects. The general public is less likely to be affected.',
      };
    } else if (aqi <= 200) {
      return {
        'name': 'Unhealthy',
        'color': aqiUnhealthy,
        'description': 'Some members of the general public may experience health effects; members of sensitive groups may experience more serious health effects.',
      };
    } else if (aqi <= 300) {
      return {
        'name': 'Very Unhealthy',
        'color': aqiVeryUnhealthy,
        'description': 'Health alert: The risk of health effects is increased for everyone.',
      };
    } else {
      return {
        'name': 'Hazardous',
        'color': aqiHazardous,
        'description': 'Health warning of emergency conditions: The entire population is more likely to be affected.',
      };
    }
  }
}

