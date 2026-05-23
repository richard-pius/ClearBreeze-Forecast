import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../utils/weather_icon_mapper.dart';

class GradientBackground extends StatelessWidget {
  final String symbolCode;
  final Widget child;

  const GradientBackground({
    super.key,
    required this.symbolCode,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final List<Color> colors = isDark
        ? WeatherIconMapper.getGradient(symbolCode)
        : WeatherIconMapper.getGradientLight(symbolCode);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
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
