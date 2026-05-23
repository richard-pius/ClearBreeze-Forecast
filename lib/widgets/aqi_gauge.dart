import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../config/theme.dart';

class AqiGauge extends StatefulWidget {
  final int aqi;

  const AqiGauge({
    super.key,
    required this.aqi,
  });

  @override
  State<AqiGauge> createState() => _AqiGaugeState();
}

class _AqiGaugeState extends State<AqiGauge> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _animation = Tween<double>(
      begin: 0.0,
      end: widget.aqi.toDouble(),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _controller.forward();
  }

  @override
  void didUpdateWidget(AqiGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.aqi != widget.aqi) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.aqi.toDouble(),
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ));
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(180, 140),
          painter: _AqiGaugePainter(
            aqi: _animation.value,
            isDark: isDark,
          ),
        );
      },
    );
  }
}

class _AqiGaugePainter extends CustomPainter {
  final double aqi;
  final bool isDark;

  _AqiGaugePainter({required this.aqi, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height - 15;
    final double radius = size.width / 2.2;
    final center = Offset(centerX, centerY);

    // Setup track paint
    final Paint trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14.0
      ..strokeCap = StrokeCap.round
      ..color = isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08);

    // Start angle is at 180 degrees (left side), sweep is a semicircle (180 deg)
    const double startAngle = math.pi;
    const double sweepAngle = math.pi;

    // Draw the background track
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      trackPaint,
    );

    // Segment the colored arc based on AQI categories
    // Scale standard: max AQI in index is 500
    // We map aqi (0 to 500) to sweep angle (0 to pi)
    final double currentSweep = (aqi.clamp(0, 500) / 500.0) * math.pi;

    // Setup active progress paint with shader/gradient
    final Paint activePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14.0
      ..strokeCap = StrokeCap.round;

    // Paint gradient color based on current value
    final Rect arcRect = Rect.fromCircle(center: center, radius: radius);
    const gradient = SweepGradient(
      startAngle: startAngle,
      endAngle: startAngle + sweepAngle,
      colors: [
        AppTheme.aqiGood,
        AppTheme.aqiModerate,
        AppTheme.aqiUnhealthySensitive,
        AppTheme.aqiUnhealthy,
        AppTheme.aqiVeryUnhealthy,
        AppTheme.aqiHazardous,
      ],
      stops: [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
    );

    activePaint.shader = gradient.createShader(arcRect);

    // Draw active arc
    if (currentSweep > 0.05) {
      canvas.drawArc(
        arcRect,
        startAngle,
        currentSweep,
        false,
        activePaint,
      );
    }

    // Draw a small indicator needle/dot at the end of the arc
    final double endAngle = startAngle + currentSweep;
    final double dotX = centerX + radius * math.cos(endAngle);
    final double dotY = centerY + radius * math.sin(endAngle);

    final Paint dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final Paint dotBorderPaint = Paint()
      ..color = AppTheme.primaryDark
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(Offset(dotX, dotY), 9.0, dotPaint);
    canvas.drawCircle(Offset(dotX, dotY), 9.0, dotBorderPaint);
  }

  @override
  bool shouldRepaint(covariant _AqiGaugePainter oldDelegate) {
    return oldDelegate.aqi != aqi;
  }
}
