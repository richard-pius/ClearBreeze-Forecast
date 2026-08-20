import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import '../models/weather_data.dart';
import '../utils/weather_icon_mapper.dart';

class WeatherService {
  final http.Client client;

  WeatherService({http.Client? client}) : client = client ?? http.Client();

  /// Fetches weather data from MET Norway Locationforecast 2.0 API.
  Future<WeatherData> fetchWeather(
      double latitude, double longitude, String locationName) async {
    // Truncate coordinates to max 4 decimal places per MET Norway requirements.
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

  /// Parses the MET Norway timeseries payload.
  ///
  /// Any field the API does not report is left as `null` in the returned
  /// model — the UI treats `null` as "not available at this location" rather
  /// than fabricating a zero or estimating.
  WeatherData _parseWeatherData(
      Map<String, dynamic> json, String locationName) {
    final Map<String, dynamic> properties = json['properties'];
    final List<dynamic> timeseries = properties['timeseries'];

    if (timeseries.isEmpty) {
      throw Exception('Empty weather timeseries data.');
    }

    // Current weather is the first point in the timeseries.
    final Map<String, dynamic> currentPoint = timeseries.first;
    final DateTime currentTime = DateTime.parse(currentPoint['time']);
    final Map<String, dynamic> currentData = currentPoint['data'];
    final Map<String, dynamic> instantDetails =
        currentData['instant']?['details'] ?? const {};

    // Temperature is required — without it the app cannot render a hero.
    final double? temperatureRaw = _toDouble(instantDetails['air_temperature']);
    if (temperatureRaw == null) {
      throw Exception(
          'Weather service returned no temperature reading for this location.');
    }
    final double temperature = temperatureRaw;

    final double? windSpeed = _toDouble(instantDetails['wind_speed']);
    final double? windDirection =
        _toDouble(instantDetails['wind_from_direction']);
    final double? humidity = _toDouble(instantDetails['relative_humidity']);
    final double? pressure =
        _toDouble(instantDetails['air_pressure_at_sea_level']);

    // Precipitation + symbol come from the next_1_hours block if it exists,
    // otherwise next_6_hours. Both may be absent at the tail of the forecast
    // horizon — in that case precipitation is null (not zero).
    double? precipitation;
    double? precipitationProbability;
    String symbolCode = 'clearsky_day'; // benign visual fallback

    final Map<String, dynamic>? next1Hour = currentData['next_1_hours'];
    if (next1Hour != null) {
      precipitation = _toDouble(next1Hour['details']?['precipitation_amount']);
      // MET Norway only ships probability_of_precipitation for Nordic
      // regions. We keep it nullable — the UI shows "not available at this
      // location" everywhere else rather than inventing a percentage.
      precipitationProbability =
          _toDouble(next1Hour['details']?['probability_of_precipitation']);
      symbolCode = next1Hour['summary']?['symbol_code'] ?? symbolCode;
    } else {
      final Map<String, dynamic>? next6Hour = currentData['next_6_hours'];
      if (next6Hour != null) {
        precipitation =
            _toDouble(next6Hour['details']?['precipitation_amount']);
        precipitationProbability =
            _toDouble(next6Hour['details']?['probability_of_precipitation']);
        symbolCode = next6Hour['summary']?['symbol_code'] ?? symbolCode;
      }
    }

    final String conditionText =
        WeatherIconMapper.getConditionDescription(symbolCode);

    // Hourly forecast for the next 24 hours.
    final List<HourlyForecast> hourlyForecasts = [];
    final int hourLimit = timeseries.length > 24 ? 24 : timeseries.length;

    for (int i = 0; i < hourLimit; i++) {
      final Map<String, dynamic> point = timeseries[i];
      final DateTime hourTime = DateTime.parse(point['time']);
      final Map<String, dynamic> pData = point['data'];
      final Map<String, dynamic> pInstantDetails =
          pData['instant']?['details'] ?? const {};

      final double? tRaw = _toDouble(pInstantDetails['air_temperature']);
      if (tRaw == null) continue; // Skip broken points rather than show 0°.

      double? prec;
      double? prob;
      String sym = 'clearsky_day';

      final Map<String, dynamic>? hNext1Hour = pData['next_1_hours'];
      if (hNext1Hour != null) {
        prec = _toDouble(hNext1Hour['details']?['precipitation_amount']);
        prob = _toDouble(hNext1Hour['details']?['probability_of_precipitation']);
        sym = hNext1Hour['summary']?['symbol_code'] ?? sym;
      } else {
        final Map<String, dynamic>? hNext6Hour = pData['next_6_hours'];
        if (hNext6Hour != null) {
          final double? sixHrPrec =
              _toDouble(hNext6Hour['details']?['precipitation_amount']);
          // Averaging preserves null-ness — if the 6-hour amount wasn't
          // reported, don't invent an hourly average.
          prec = sixHrPrec == null ? null : sixHrPrec / 6.0;
          prob =
              _toDouble(hNext6Hour['details']?['probability_of_precipitation']);
          sym = hNext6Hour['summary']?['symbol_code'] ?? sym;
        }
      }

      hourlyForecasts.add(HourlyForecast(
        time: hourTime,
        temperature: tRaw,
        precipitation: prec,
        precipitationProbability: prob,
        symbolCode: sym,
      ));
    }

    // Daily forecast — group timeseries points by local calendar day.
    final Map<String, List<Map<String, dynamic>>> groupedPoints = {};
    for (var point in timeseries) {
      final DateTime date = DateTime.parse(point['time']).toLocal();
      final String dateKey =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      (groupedPoints[dateKey] ??= []).add(point);
    }

    final List<String> sortedKeys = groupedPoints.keys.toList()..sort();
    final int dayLimit = sortedKeys.length > 7 ? 7 : sortedKeys.length;
    final List<DailyForecast> dailyForecasts = [];

    for (int d = 0; d < dayLimit; d++) {
      final String dateKey = sortedKeys[d];
      final List<Map<String, dynamic>> points = groupedPoints[dateKey]!;
      final DateTime date = DateTime.parse('${dateKey}T00:00:00');

      double tMin = double.infinity;
      double tMax = -double.infinity;
      double? totalPrec; // null until we see at least one reported value.
      double? maxProb; // null unless the API actually reports a probability.
      final Map<String, int> symbolCount = {};

      for (var point in points) {
        final Map<String, dynamic> dataBlock = point['data'];
        final Map<String, dynamic>? instant = dataBlock['instant'];
        if (instant != null) {
          final double? temp = _toDouble(instant['details']?['air_temperature']);
          if (temp != null) {
            if (temp < tMin) tMin = temp;
            if (temp > tMax) tMax = temp;
          }
        }

        final Map<String, dynamic>? next6h = dataBlock['next_6_hours'];
        if (next6h != null) {
          final double? precAmt =
              _toDouble(next6h['details']?['precipitation_amount']);
          if (precAmt != null) {
            totalPrec = (totalPrec ?? 0) + precAmt;
          }
          final double? prob = _toDouble(
              next6h['details']?['probability_of_precipitation']);
          if (prob != null && (maxProb == null || prob > maxProb)) {
            maxProb = prob;
          }
          final String? code = next6h['summary']?['symbol_code'];
          if (code != null) {
            symbolCount[code] = (symbolCount[code] ?? 0) + 1;
          }
        }
      }

      // Fall back to current temp only when we saw literally no readings.
      if (tMin == double.infinity) tMin = temperature;
      if (tMax == -double.infinity) tMax = temperature;

      // Modal symbol for the day.
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
      precipitationProbability: precipitationProbability,
      symbolCode: symbolCode,
      conditionText: conditionText,
      time: currentTime,
      hourlyForecasts: hourlyForecasts,
      dailyForecasts: dailyForecasts,
    );
  }

  /// Parses a numeric value from the JSON. Returns `null` when the value is
  /// `null` (or non-numeric) — the UI treats that as "not reported at this
  /// location" rather than falling back to 0.
  double? _toDouble(dynamic val) {
    if (val == null) return null;
    if (val is int) return val.toDouble();
    if (val is double) return val;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val);
    return null;
  }
}
