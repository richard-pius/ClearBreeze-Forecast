import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../config/constants.dart';
import '../models/air_quality_data.dart';
import 'aqi_calculator.dart';

class AirQualityService {
  final http.Client client;

  AirQualityService({http.Client? client}) : client = client ?? http.Client();

  /// Fetches Air Quality data near coordinates.
  /// If the API key is the default placeholder, it falls back to Demo Mode with simulated data.
  Future<AirQualityData> fetchAirQuality(double lat, double lon) async {
    // Check if API key is still the placeholder
    if (Constants.openaqApiKey == 'YOUR_OPENAQ_API_KEY_HERE' || 
        Constants.openaqApiKey.trim().isEmpty) {
      debugPrint('OpenAQ API Key is not set. Falling back to Demo Mode simulated data.');
      return _generateSimulatedData(lat, lon);
    }

    try {
      // Step 1: Find the nearest location (monitoring station) within search radius
      final Uri locationsUrl = Uri.parse(
        '${Constants.openaqBaseUrl}/locations?coordinates=$lat,$lon&radius=${Constants.openaqSearchRadius}&limit=1',
      );

      final http.Response locationsResponse = await client.get(
        locationsUrl,
        headers: {
          'X-API-Key': Constants.openaqApiKey,
          'Accept': 'application/json',
        },
      );

      if (locationsResponse.statusCode != 200) {
        throw Exception('OpenAQ Locations request failed with status: ${locationsResponse.statusCode}');
      }

      final Map<String, dynamic> locationsJson = jsonDecode(locationsResponse.body);
      final List<dynamic> locationsResults = locationsJson['results'] ?? [];

      if (locationsResults.isEmpty) {
        // No stations nearby, return empty/no data state
        return AirQualityData(
          aqi: 0,
          category: 'No Stations Nearby',
          stationName: 'No station within 25km',
          lastUpdated: DateTime.now(),
        );
      }

      // Select the closest station (first result)
      final Map<String, dynamic> nearestStation = locationsResults.first;
      final int stationId = nearestStation['id'];
      final String stationName = nearestStation['name'] ?? 'Unnamed Station';
      final List<dynamic> sensors = nearestStation['sensors'] ?? [];
      
      final double stationLat = nearestStation['coordinates']?['latitude'] ?? lat;
      final double stationLon = nearestStation['coordinates']?['longitude'] ?? lon;

      // Calculate distance between user coordinates and the station
      final double distanceInMeters = Geolocator.distanceBetween(lat, lon, stationLat, stationLon);
      final double distanceInKm = double.parse((distanceInMeters / 1000).toStringAsFixed(1));

      // Build mapping from sensor ID to parameter name
      final Map<int, String> sensorParameterMap = {};
      for (var sensor in sensors) {
        final int sensorId = sensor['id'];
        final String paramName = sensor['parameter']?['name']?.toString().toLowerCase() ?? '';
        sensorParameterMap[sensorId] = paramName;
      }

      // Step 2: Fetch latest measurements for this specific location
      final Uri latestUrl = Uri.parse('${Constants.openaqBaseUrl}/locations/$stationId/latest');
      final http.Response latestResponse = await client.get(
        latestUrl,
        headers: {
          'X-API-Key': Constants.openaqApiKey,
          'Accept': 'application/json',
        },
      );

      if (latestResponse.statusCode != 200) {
        throw Exception('OpenAQ Latest request failed with status: ${latestResponse.statusCode}');
      }

      final Map<String, dynamic> latestJson = jsonDecode(latestResponse.body);
      final List<dynamic> measurements = latestJson['results'] ?? [];

      double? pm25;
      double? pm10;
      double? o3;
      double? no2;
      double? so2;
      double? co;
      DateTime lastUpdated = DateTime.now();

      // Map values based on sensor ID
      for (var m in measurements) {
        final int sensorId = m['sensorsId'];
        final double value = (m['value'] as num).toDouble();
        final String? paramName = sensorParameterMap[sensorId];
        
        final String utcTime = m['datetime']?['utc'] ?? '';
        if (utcTime.isNotEmpty) {
          lastUpdated = DateTime.parse(utcTime);
        }

        if (paramName != null) {
          switch (paramName) {
            case 'pm25':
            case 'pm2.5':
              pm25 = value;
              break;
            case 'pm10':
              pm10 = value;
              break;
            case 'o3':
            case 'ozone':
              o3 = value;
              break;
            case 'no2':
              no2 = value;
              break;
            case 'so2':
              so2 = value;
              break;
            case 'co':
              co = value;
              break;
          }
        }
      }

      // Step 3: Calculate AQI using EPA formula
      final int aqi = AqiCalculator.calculateAqi(pm25: pm25, pm10: pm10);
      final String category = AqiCalculator.getCategory(aqi);

      return AirQualityData(
        aqi: aqi,
        category: category,
        pm25: pm25,
        pm10: pm10,
        o3: o3,
        no2: no2,
        so2: so2,
        co: co,
        stationName: stationName,
        distanceKm: distanceInKm,
        lastUpdated: lastUpdated.toLocal(),
      );

    } catch (e) {
      debugPrint('OpenAQ fetching error: $e');
      throw Exception('Failed to load air quality data: $e');
    }
  }

  /// Generates mock data for Demo Mode. This allows the app to run without API key.
  AirQualityData _generateSimulatedData(double lat, double lon) {
    // Deterministic simulation based on coordinates so the data is stable
    final int baseAqi = ((lat.abs() + lon.abs()) * 10).round() % 120 + 25; // range 25 to 145
    
    // Set PM values according to the simulated AQI
    double pm25;
    double pm10;

    if (baseAqi <= 50) {
      pm25 = baseAqi * 0.2; // 0 to 10
      pm10 = baseAqi * 0.8; // 0 to 40
    } else if (baseAqi <= 100) {
      pm25 = 12.0 + (baseAqi - 50) * 0.46; // 12 to 35
      pm10 = 54.0 + (baseAqi - 50) * 2.0;  // 54 to 154
    } else {
      pm25 = 35.0 + (baseAqi - 100) * 0.4; // 35 to 55
      pm10 = 154.0 + (baseAqi - 100) * 2.0; // 154 to 254
    }

    final int finalAqi = AqiCalculator.calculateAqi(pm25: pm25, pm10: pm10);
    final String category = AqiCalculator.getCategory(finalAqi);

    return AirQualityData(
      aqi: finalAqi,
      category: category,
      pm25: double.parse(pm25.toStringAsFixed(1)),
      pm10: double.parse(pm10.toStringAsFixed(1)),
      o3: 0.035,
      no2: 12.0,
      so2: 1.5,
      co: 0.4,
      stationName: 'Simulation Station (Demo)',
      distanceKm: 2.4,
      lastUpdated: DateTime.now(),
    );
  }
}
