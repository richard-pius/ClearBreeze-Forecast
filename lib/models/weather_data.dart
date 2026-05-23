import 'dart:math' as math;

class WeatherData {
  final double temperature;
  final double windSpeed;
  final double windDirection;
  final double humidity;
  final double pressure;
  final double precipitation;
  final double precipitationProbability;
  final String symbolCode;
  final String conditionText;
  final DateTime time;
  final List<HourlyForecast> hourlyForecasts;
  final List<DailyForecast> dailyForecasts;

  WeatherData({
    required this.temperature,
    required this.windSpeed,
    required this.windDirection,
    required this.humidity,
    required this.pressure,
    required this.precipitation,
    required this.precipitationProbability,
    required this.symbolCode,
    required this.conditionText,
    required this.time,
    required this.hourlyForecasts,
    required this.dailyForecasts,
  });

  // Basic calculation for Apparent ("Feels Like") Temperature
  // Heat Index (for hot temp) and Wind Chill (for cold temp) approximation
  double get feelsLike {
    if (temperature >= 27) {
      // Simple Heat Index approximation
      return temperature + 0.05 * ((humidity - 50) + (temperature - 27));
    } else if (temperature <= 10 && windSpeed > 1.3) {
      // Simple Wind Chill approximation
      // Wind speed must be in km/h for the formula: windSpeed * 3.6
      final double v = windSpeed * 3.6;
      return 13.12 + 0.6215 * temperature - 11.37 * math.pow(v, 0.16) + 0.3965 * temperature * math.pow(v, 0.16);
    }
    return temperature;
  }
}

class HourlyForecast {
  final DateTime time;
  final double temperature;
  final double precipitation;
  final double precipitationProbability;
  final String symbolCode;

  HourlyForecast({
    required this.time,
    required this.temperature,
    required this.precipitation,
    required this.precipitationProbability,
    required this.symbolCode,
  });
}

class DailyForecast {
  final DateTime date;
  final double tempMin;
  final double tempMax;
  final double totalPrecipitation;
  final double maxPrecipitationProbability;
  final String symbolCode;

  DailyForecast({
    required this.date,
    required this.tempMin,
    required this.tempMax,
    required this.totalPrecipitation,
    required this.maxPrecipitationProbability,
    required this.symbolCode,
  });
}
