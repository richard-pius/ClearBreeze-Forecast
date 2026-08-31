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

  /// Fetches live air quality near the given coordinates.
  ///
  /// This method never throws and never fabricates data. When a real AQI
  /// cannot be produced — no API key, no nearby station, no PM readings, or
  /// a network failure — it returns [AirQualityData.unavailable] carrying the
  /// reason, so the UI can tell the user exactly what is missing and why.
  Future<AirQualityData> fetchAirQuality(double lat, double lon) async {
    if (Constants.openaqApiKey.trim().isEmpty ||
        Constants.openaqApiKey == 'YOUR_OPENAQ_API_KEY_HERE') {
      debugPrint(
        'OpenAQ API key is not configured; air quality will show as unavailable.',
      );
      return AirQualityData.unavailable(AqiUnavailableReason.notConfigured);
    }

    try {
      // Step 1: Find the nearest monitoring station within the search radius.
      final Uri locationsUrl = Uri.parse(
        '${Constants.openaqBaseUrl}/locations'
        '?coordinates=$lat,$lon'
        '&radius=${Constants.openaqSearchRadius}&limit=1',
      );

      final http.Response locationsResponse = await client.get(
        locationsUrl,
        headers: {
          'X-API-Key': Constants.openaqApiKey,
          'Accept': 'application/json',
        },
      );

      if (locationsResponse.statusCode != 200) {
        debugPrint(
          'OpenAQ locations request failed: ${locationsResponse.statusCode}',
        );
        return AirQualityData.unavailable(AqiUnavailableReason.fetchFailed);
      }

      final Map<String, dynamic> locationsJson = jsonDecode(
        locationsResponse.body,
      );
      final List<dynamic> locationsResults = locationsJson['results'] ?? [];

      if (locationsResults.isEmpty) {
        return AirQualityData.unavailable(AqiUnavailableReason.noStationNearby);
      }

      final Map<String, dynamic> nearestStation = locationsResults.first;
      final int stationId = nearestStation['id'];
      final String stationName =
          nearestStation['name']?.toString() ?? 'Unnamed station';
      final List<dynamic> sensors = nearestStation['sensors'] ?? [];

      final double stationLat =
          _toDouble(nearestStation['coordinates']?['latitude']) ?? lat;
      final double stationLon =
          _toDouble(nearestStation['coordinates']?['longitude']) ?? lon;

      final double distanceKm = double.parse(
        (Geolocator.distanceBetween(lat, lon, stationLat, stationLon) / 1000)
            .toStringAsFixed(1),
      );

      // Map sensor IDs to the parameter each one measures.
      final Map<int, String> sensorParameterMap = {};
      for (final sensor in sensors) {
        final int? sensorId = sensor['id'] as int?;
        if (sensorId == null) continue;
        sensorParameterMap[sensorId] =
            sensor['parameter']?['name']?.toString().toLowerCase() ?? '';
      }

      // Step 2: Fetch the latest measurements for that station.
      final Uri latestUrl = Uri.parse(
        '${Constants.openaqBaseUrl}/locations/$stationId/latest',
      );
      final http.Response latestResponse = await client.get(
        latestUrl,
        headers: {
          'X-API-Key': Constants.openaqApiKey,
          'Accept': 'application/json',
        },
      );

      if (latestResponse.statusCode != 200) {
        debugPrint(
          'OpenAQ latest request failed: ${latestResponse.statusCode}',
        );
        return AirQualityData.unavailable(
          AqiUnavailableReason.fetchFailed,
          stationName: stationName,
          distanceKm: distanceKm,
        );
      }

      final Map<String, dynamic> latestJson = jsonDecode(latestResponse.body);
      final List<dynamic> measurements = latestJson['results'] ?? [];

      double? pm25, pm10, o3, no2, so2, co;
      DateTime? lastUpdated;

      for (final m in measurements) {
        final int? sensorId = m['sensorsId'] as int?;
        final double? value = _toDouble(m['value']);
        if (sensorId == null || value == null) continue;

        final String utcTime = m['datetime']?['utc']?.toString() ?? '';
        if (utcTime.isNotEmpty) {
          lastUpdated = DateTime.tryParse(utcTime) ?? lastUpdated;
        }

        switch (sensorParameterMap[sensorId]) {
          case 'pm25':
          case 'pm2.5':
            pm25 = value;
          case 'pm10':
            pm10 = value;
          case 'o3':
          case 'ozone':
            o3 = value;
          case 'no2':
            no2 = value;
          case 'so2':
            so2 = value;
          case 'co':
            co = value;
        }
      }

      // Step 3: Compute the AQI. Null means the station reported neither
      // PM2.5 nor PM10, so no EPA index can be derived.
      final int? aqi = AqiCalculator.calculateAqi(pm25: pm25, pm10: pm10);

      if (aqi == null) {
        return AirQualityData.unavailable(
          AqiUnavailableReason.noMeasurements,
          stationName: stationName,
          distanceKm: distanceKm,
          // Any secondary pollutants the station *did* report are still
          // passed through so the card can display them.
          o3: o3,
          no2: no2,
          so2: so2,
          co: co,
          lastUpdated: lastUpdated?.toLocal(),
        );
      }

      return AirQualityData(
        aqi: aqi,
        category: AqiCalculator.getCategory(aqi),
        pm25: pm25,
        pm10: pm10,
        o3: o3,
        no2: no2,
        so2: so2,
        co: co,
        stationName: stationName,
        distanceKm: distanceKm,
        lastUpdated: (lastUpdated ?? DateTime.now()).toLocal(),
      );
    } catch (e) {
      debugPrint('OpenAQ fetch error: $e');
      return AirQualityData.unavailable(AqiUnavailableReason.fetchFailed);
    }
  }

  double? _toDouble(dynamic val) {
    if (val == null) return null;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val);
    return null;
  }
}
