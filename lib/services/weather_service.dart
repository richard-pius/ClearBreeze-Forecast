import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import '../models/weather_data.dart';
import '../utils/weather_icon_mapper.dart';

class WeatherService {
  final http.Client client;

  WeatherService({http.Client? client}) : client = client ?? http.Client();

  /// Fetches weather data from MET Norway Locationforecast 2.0 API.
  Future<WeatherData> fetchWeather(double latitude, double longitude, String locationName) async {
    // 1. Truncate coordinates to max 4 decimal places per MET Norway requirements (improves caching)
    final double lat = double.parse(latitude.toStringAsFixed(4));
    final double lon = double.parse(longitude.toStringAsFixed(4));

    final Uri url = Uri.parse('${Constants.weatherBaseUrl}?lat=$lat&lon=$lon');

    try {
      final http.Response response = await client.get(
        url,
        headers: {
          'User-Agent': Constants.weatherUserAgent,
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return _parseWeatherData(data, locationName);
      } else {
        throw Exception(
            'Failed to load weather data. Error code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error while fetching weather: $e');
    }
  }

  /// Parses the complex MET Norway timeseries JSON payload into WeatherData model
  WeatherData _parseWeatherData(Map<String, dynamic> json, String locationName) {
    final Map<String, dynamic> properties = json['properties'];
    final List<dynamic> timeseries = properties['timeseries'];

    if (timeseries.isEmpty) {
      throw Exception('Empty weather timeseries data.');
    }

    // Current weather is the first point in the timeseries
    final Map<String, dynamic> currentPoint = timeseries.first;
    final String timeStr = currentPoint['time'];
    final DateTime currentTime = DateTime.parse(timeStr);
    final Map<String, dynamic> currentData = currentPoint['data'];
    final Map<String, dynamic> instantDetails = currentData['instant']['details'];

    // Extract current metrics
    final double temperature = _toDouble(instantDetails['air_temperature']);
    final double windSpeed = _toDouble(instantDetails['wind_speed']);
    final double windDirection = _toDouble(instantDetails['wind_from_direction']);
    final double humidity = _toDouble(instantDetails['relative_humidity']);
    final double pressure = _toDouble(instantDetails['air_pressure_at_sea_level']);

    // Next 1 hour aggregations for current precipitation/prob
    double precipitation = 0.0;
    double rainProbability = 0.0;
    String symbolCode = 'clearsky_day'; // fallback

    final Map<String, dynamic>? next1Hour = currentData['next_1_hours'];
    if (next1Hour != null) {
      precipitation = _toDouble(next1Hour['details']?['precipitation_amount']);
      rainProbability = _toDouble(next1Hour['details']?['probability_of_precipitation']);
      symbolCode = next1Hour['summary']?['symbol_code'] ?? symbolCode;
    } else {
      // Try next 6 hours if next 1 hour is null (unlikely for current point)
      final Map<String, dynamic>? next6Hour = currentData['next_6_hours'];
      if (next6Hour != null) {
        precipitation = _toDouble(next6Hour['details']?['precipitation_amount']);
        rainProbability = _toDouble(next6Hour['details']?['probability_of_precipitation']);
        symbolCode = next6Hour['summary']?['symbol_code'] ?? symbolCode;
      }
    }

    final String conditionText = WeatherIconMapper.getConditionDescription(symbolCode);

    // 2. Parse hourly forecast for next 24 hours
    final List<HourlyForecast> hourlyForecasts = [];
    final int hourLimit = timeseries.length > 24 ? 24 : timeseries.length;

    for (int i = 0; i < hourLimit; i++) {
      final Map<String, dynamic> point = timeseries[i];
      final DateTime hourTime = DateTime.parse(point['time']);
      final Map<String, dynamic> pData = point['data'];
      final Map<String, dynamic> pInstantDetails = pData['instant']['details'];
      
      final double temp = _toDouble(pInstantDetails['air_temperature']);
      double prec = 0.0;
      double prob = 0.0;
      String sym = 'clearsky_day';

      final Map<String, dynamic>? hNext1Hour = pData['next_1_hours'];
      if (hNext1Hour != null) {
        prec = _toDouble(hNext1Hour['details']?['precipitation_amount']);
        prob = _toDouble(hNext1Hour['details']?['probability_of_precipitation']);
        sym = hNext1Hour['summary']?['symbol_code'] ?? sym;
      } else {
        final Map<String, dynamic>? hNext6Hour = pData['next_6_hours'];
        if (hNext6Hour != null) {
          prec = _toDouble(hNext6Hour['details']?['precipitation_amount']) / 6.0; // average hourly
          prob = _toDouble(hNext6Hour['details']?['probability_of_precipitation']);
          sym = hNext6Hour['summary']?['symbol_code'] ?? sym;
        }
      }

      hourlyForecasts.add(HourlyForecast(
        time: hourTime,
        temperature: temp,
        precipitation: prec,
        precipitationProbability: prob,
        symbolCode: sym,
      ));
    }

    // 3. Parse daily forecast (group timeseries by day for the next 7 days)
    final List<DailyForecast> dailyForecasts = [];
    final Map<String, List<Map<String, dynamic>>> groupedPoints = {};

    for (var point in timeseries) {
      final DateTime date = DateTime.parse(point['time']).toLocal();
      final String dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      // Skip current day if it's already mostly past, or just group all
      if (!groupedPoints.containsKey(dateKey)) {
        groupedPoints[dateKey] = [];
      }
      groupedPoints[dateKey]!.add(point);
    }

    // Process up to 7 distinct days
    final List<String> sortedKeys = groupedPoints.keys.toList()..sort();
    final int dayLimit = sortedKeys.length > 7 ? 7 : sortedKeys.length;

    for (int d = 0; d < dayLimit; d++) {
      final String dateKey = sortedKeys[d];
      final List<Map<String, dynamic>> points = groupedPoints[dateKey]!;
      final DateTime date = DateTime.parse('${dateKey}T00:00:00');

      double tMin = double.infinity;
      double tMax = -double.infinity;
      double totalPrec = 0.0;
      double maxProb = 0.0;
      final Map<String, int> symbolCount = {};

      for (var point in points) {
        final Map<String, dynamic> dataBlock = point['data'];
        final Map<String, dynamic>? instant = dataBlock['instant'];
        if (instant != null) {
          final double temp = _toDouble(instant['details']?['air_temperature']);
          if (temp < tMin) tMin = temp;
          if (temp > tMax) tMax = temp;
        }

        // Sum precipitation and find max probability in the 6-hour blocks
        final Map<String, dynamic>? next6h = dataBlock['next_6_hours'];
        if (next6h != null) {
          totalPrec += _toDouble(next6h['details']?['precipitation_amount']);
          final double prob = _toDouble(next6h['details']?['probability_of_precipitation']);
          if (prob > maxProb) maxProb = prob;

          final String? code = next6h['summary']?['symbol_code'];
          if (code != null) {
            symbolCount[code] = (symbolCount[code] ?? 0) + 1;
          }
        }
      }

      // Fallbacks in case max/min/etc were not populated
      if (tMin == double.infinity) tMin = temperature;
      if (tMax == -double.infinity) tMax = temperature;

      // Select most common symbol code for the day
      String modalSymbol = symbolCode;
      int maxCount = 0;
      symbolCount.forEach((key, count) {
        if (count > maxCount) {
          maxCount = count;
          modalSymbol = key;
        }
      });

      dailyForecasts.add(DailyForecast(
        date: date,
        tempMin: tMin,
        tempMax: tMax,
        totalPrecipitation: totalPrec,
        maxPrecipitationProbability: maxProb,
        symbolCode: modalSymbol,
      ));
    }

    return WeatherData(
      temperature: temperature,
      windSpeed: windSpeed,
      windDirection: windDirection,
      humidity: humidity,
      pressure: pressure,
      precipitation: precipitation,
      precipitationProbability: rainProbability,
      symbolCode: symbolCode,
      conditionText: conditionText,
      time: currentTime,
      hourlyForecasts: hourlyForecasts,
      dailyForecasts: dailyForecasts,
    );
  }

  double _toDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is int) return val.toDouble();
    if (val is double) return val;
    return 0.0;
  }
}
