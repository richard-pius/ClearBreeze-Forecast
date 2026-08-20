import 'dart:math' as math;

/// Weather snapshot for one location.
///
/// Every optional metric is nullable so the UI can distinguish
/// "API did not report this at this location" from a genuine zero. Only
/// [temperature], [symbolCode], [conditionText] and [time] are required —
/// the parser throws if the top-level `air_temperature` isn't in the payload,
/// because without a temperature there is no meaningful weather to show.
class WeatherData {
  final double temperature;
  final double? windSpeed;
  final double? windDirection;
  final double? humidity;
  final double? pressure;
  final double? precipitation;
  final double? precipitationProbability;
  final String symbolCode;
  final String conditionText;
  final DateTime time;
  final List<HourlyForecast> hourlyForecasts;
  final List<DailyForecast> dailyForecasts;

  WeatherData({
    required this.temperature,
    this.windSpeed,
    this.windDirection,
    this.humidity,
    this.pressure,
    this.precipitation,
    this.precipitationProbability,
    required this.symbolCode,
    required this.conditionText,
    required this.time,
    required this.hourlyForecasts,
    required this.dailyForecasts,
  });

  /// Apparent ("Feels Like") temperature.
  ///
  /// Uses the heat-index approximation on hot, humid days and the wind-chill
  /// approximation on cold, windy days. Falls back to the raw temperature
  /// when the required inputs (humidity for heat index, wind speed for wind
  /// chill) are not reported by the API at this location.
  double get feelsLike {
    if (temperature >= 27 && humidity != null) {
      return temperature + 0.05 * ((humidity! - 50) + (temperature - 27));
    }
    if (temperature <= 10 && windSpeed != null && windSpeed! > 1.3) {
      // Wind speed must be in km/h for the formula: windSpeed * 3.6
      final double v = windSpeed! * 3.6;
      return 13.12 +
          0.6215 * temperature -
          11.37 * math.pow(v, 0.16) +
          0.3965 * temperature * math.pow(v, 0.16);
    }
    return temperature;
  }
}

class HourlyForecast {
  final DateTime time;
  final double temperature;
  final double? precipitation;
  final double? precipitationProbability;
  final String symbolCode;

  HourlyForecast({
    required this.time,
    required this.temperature,
    this.precipitation,
    this.precipitationProbability,
    required this.symbolCode,
  });
}

class DailyForecast {
  final DateTime date;
  final double tempMin;
  final double tempMax;
  final double? totalPrecipitation;
  final double? maxPrecipitationProbability;
  final String symbolCode;

  DailyForecast({
    required this.date,
    required this.tempMin,
    required this.tempMax,
    this.totalPrecipitation,
    this.maxPrecipitationProbability,
    required this.symbolCode,
  });
}
