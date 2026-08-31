import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../config/constants.dart';
import '../models/air_quality_data.dart';
import '../models/weather_data.dart';
import '../services/air_quality_service.dart';
import '../services/location_service.dart';
import '../services/weather_service.dart';

enum WeatherState { initial, loading, loaded, error }

class WeatherProvider extends ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  final AirQualityService _aqiService = AirQualityService();

  WeatherState _state = WeatherState.initial;
  WeatherState get state => _state;

  WeatherData? _weatherData;
  WeatherData? get weatherData => _weatherData;

  AirQualityData? _aqiData;
  AirQualityData? get aqiData => _aqiData;

  String _locationName = 'Loading Location...';
  String get locationName => _locationName;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  String _tempUnit = 'C';
  String get tempUnit => _tempUnit;

  bool get isCelsius => _tempUnit == 'C';

  // Search state
  bool _isSearchMode = false;
  bool get isSearchMode => _isSearchMode;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  // Recent searches
  List<String> _recentSearches = [];
  List<String> get recentSearches => _recentSearches;

  WeatherProvider() {
    _loadUserPreferences();
  }

  /// Load persisted settings from shared preferences.
  Future<void> _loadUserPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _tempUnit = prefs.getString(Constants.keyTempUnit) ?? 'C';

    final String? searchesJson = prefs.getString(Constants.keyRecentSearches);
    if (searchesJson != null) {
      try {
        _recentSearches = List<String>.from(jsonDecode(searchesJson));
      } catch (e) {
        debugPrint('Discarding corrupt recent-searches cache: $e');
        _recentSearches = [];
      }
    }

    notifyListeners();
  }

  /// Toggle between Celsius and Fahrenheit.
  Future<void> toggleTempUnit() async {
    _tempUnit = _tempUnit == 'C' ? 'F' : 'C';
    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(Constants.keyTempUnit, _tempUnit);
  }

  /// Convert a Celsius value into the unit the user has selected.
  double formatTemperature(double tempCelsius) {
    if (_tempUnit == 'F') {
      return (tempCelsius * 9 / 5) + 32;
    }
    return tempCelsius;
  }

  /// Fetch weather + air quality for the device's GPS location.
  Future<void> fetchWeatherData({bool isRefresh = false}) async {
    if (!isRefresh) {
      _state = WeatherState.loading;
      notifyListeners();
    }

    try {
      final position = await LocationService.getCurrentLocation();

      _locationName = await LocationService.getCityFromCoordinates(
        position.latitude,
        position.longitude,
      );
      _isSearchMode = false;
      _searchQuery = '';
      notifyListeners();

      await _load(position.latitude, position.longitude);
    } catch (e) {
      _fail(e);
    }

    notifyListeners();
  }

  /// Fetch weather for a searched city / area name.
  Future<void> fetchWeatherForCity(String cityName) async {
    if (cityName.trim().isEmpty) return;

    _state = WeatherState.loading;
    _searchQuery = cityName.trim();
    notifyListeners();

    try {
      final List<Location> locations = await locationFromAddress(cityName);
      if (locations.isEmpty) {
        throw Exception(
          'Could not find location "$cityName". Try a different name.',
        );
      }

      final Location loc = locations.first;
      _locationName = await LocationService.getCityFromCoordinates(
        loc.latitude,
        loc.longitude,
      );
      _isSearchMode = true;
      notifyListeners();

      await _load(loc.latitude, loc.longitude);
      if (_state == WeatherState.loaded) {
        await _addToRecentSearches(cityName.trim());
      }
    } catch (e) {
      _fail(e);
    }

    notifyListeners();
  }

  /// Fetch weather for explicit coordinates and a display name.
  Future<void> fetchWeatherForCoordinates(
    double lat,
    double lon,
    String displayName,
  ) async {
    _state = WeatherState.loading;
    _searchQuery = displayName;
    _locationName = displayName;
    _isSearchMode = true;
    notifyListeners();

    try {
      await _load(lat, lon);
      if (_state == WeatherState.loaded) {
        await _addToRecentSearches(displayName);
      }
    } catch (e) {
      _fail(e);
    }

    notifyListeners();
  }

  /// Shared load path for every entry point.
  ///
  /// Weather is required — if it fails, the screen shows an error. Air
  /// quality is supplementary: [AirQualityService] resolves to an
  /// "unavailable" record instead of throwing, so a missing AQI never hides
  /// an otherwise perfectly good forecast.
  Future<void> _load(double lat, double lon) async {
    final results = await (
      _weatherService.fetchWeather(lat, lon, _locationName),
      _aqiService.fetchAirQuality(lat, lon).catchError((Object e) {
        debugPrint('Air quality lookup failed: $e');
        return AirQualityData.unavailable(AqiUnavailableReason.fetchFailed);
      }),
    ).wait;

    _weatherData = results.$1;
    _aqiData = results.$2;
    _state = WeatherState.loaded;
    _errorMessage = '';
  }

  void _fail(Object e) {
    _errorMessage = e.toString().replaceAll('Exception: ', '');
    _state = WeatherState.error;
  }

  /// Clear search and return to the GPS location.
  Future<void> clearSearch() async {
    _isSearchMode = false;
    _searchQuery = '';
    await fetchWeatherData();
  }

  /// Add a city to recent searches (max 10, most recent first, no dupes).
  Future<void> _addToRecentSearches(String city) async {
    _recentSearches.remove(city);
    _recentSearches.insert(0, city);

    if (_recentSearches.length > 10) {
      _recentSearches = _recentSearches.sublist(0, 10);
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      Constants.keyRecentSearches,
      jsonEncode(_recentSearches),
    );
  }

  /// Remove one entry from recent searches.
  Future<void> removeRecentSearch(String city) async {
    _recentSearches.remove(city);
    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      Constants.keyRecentSearches,
      jsonEncode(_recentSearches),
    );
  }

  /// Clear all recent searches.
  Future<void> clearRecentSearches() async {
    _recentSearches.clear();
    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(Constants.keyRecentSearches);
  }
}
