import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';

class LocationService {
  /// Request permissions and get current position (latitude/longitude)
  static Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled. Please enable GPS in settings.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permission was denied. We need it to fetch your local weather.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied. Please enable them in your app settings.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      timeLimit: Duration(seconds: 10),
    );
    return await Geolocator.getCurrentPosition(
      locationSettings: locationSettings,
    );
  }

  /// Convert coordinates into a user-friendly city or area name
  static Future<String> getCityFromCoordinates(double lat, double lon) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks.first;
        
        // Locality is typically the city name. SubLocality is the district.
        final String? city = place.locality ?? place.subLocality ?? place.name;
        final String? country = place.country;

        if (city != null && country != null) {
          return '$city, $country';
        } else if (city != null) {
          return city;
        }
      }
    } catch (e) {
      // Return a clean coordinate string if geocoding fails or is rate-limited
      debugPrint('Geocoding error: $e');
    }
    return '${lat.toStringAsFixed(3)}°, ${lon.toStringAsFixed(3)}°';
  }

  /// Finds up to 5 matching cities for a search query by geocoding + reverse-geocoding coordinates.
  static Future<List<Map<String, dynamic>>> getSimilarCities(String query) async {
    if (query.trim().isEmpty) return [];
    try {
      final List<Location> locations = await locationFromAddress(query);
      final List<Map<String, dynamic>> results = [];
      
      // Limit to top 5 results to avoid hitting rate limits or slow performance
      final int limit = locations.length > 5 ? 5 : locations.length;
      for (int i = 0; i < limit; i++) {
        final Location loc = locations[i];
        try {
          final List<Placemark> placemarks = await placemarkFromCoordinates(loc.latitude, loc.longitude);
          if (placemarks.isNotEmpty) {
            final Placemark place = placemarks.first;
            
            // Build a descriptive name
            final String? city = place.locality ?? place.subLocality ?? place.name;
            final String? adminArea = place.administrativeArea;
            final String? country = place.country;
            
            String displayName = '';
            if (city != null) {
              displayName = city;
              if (adminArea != null && adminArea.isNotEmpty) {
                displayName += ', $adminArea';
              }
              if (country != null && country.isNotEmpty) {
                displayName += ', $country';
              }
            } else {
              displayName = '${loc.latitude.toStringAsFixed(3)}°, ${loc.longitude.toStringAsFixed(3)}°';
            }
            
            // Avoid duplicates
            if (!results.any((r) => r['name'] == displayName)) {
              results.add({
                'name': displayName,
                'latitude': loc.latitude,
                'longitude': loc.longitude,
              });
            }
          }
        } catch (e) {
          final String coordName = '${loc.latitude.toStringAsFixed(3)}°, ${loc.longitude.toStringAsFixed(3)}°';
          if (!results.any((r) => r['name'] == coordName)) {
            results.add({
              'name': coordName,
              'latitude': loc.latitude,
              'longitude': loc.longitude,
            });
          }
        }
      }
      return results;
    } catch (e) {
      debugPrint('Error finding similar cities: $e');
      return [];
    }
  }
}
