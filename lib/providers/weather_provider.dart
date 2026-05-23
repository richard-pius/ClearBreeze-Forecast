import 'package:flutter/material.dart';
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

  /// Load temperature unit setting from shared preferences
  Future<void> _loadUserPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _tempUnit = prefs.getString(Constants.keyTempUnit) ?? 'C';
    
    // Load recent searches
    final String? searchesJson = prefs.getString(Constants.keyRecentSearches);
    if (searchesJson != null) {
      _recentSearches = List<String>.from(jsonDecode(searchesJson));
    }
    
    notifyListeners();
  }

  /// Toggle between Celsius and Fahrenheit
  Future<void> toggleTempUnit() async {
    _tempUnit = _tempUnit == 'C' ? 'F' : 'C';
    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(Constants.keyTempUnit, _tempUnit);
  }

  /// Helper to convert temperature to correct unit for UI display
  double formatTemperature(double tempCelsius) {
    if (_tempUnit == 'F') {
      return (tempCelsius * 9 / 5) + 32;
    }
    return tempCelsius;
  }

  /// Main method to fetch weather and air quality for the current GPS location
  Future<void> fetchWeatherData({bool isRefresh = false}) async {
    if (!isRefresh) {
      _state = WeatherState.loading;
      notifyListeners();
    }

    try {
      // 1. Get user GPS location
      final position = await LocationService.getCurrentLocation();
      
      // 2. Perform reverse geocoding to get City/Country name
      _locationName = await LocationService.getCityFromCoordinates(
        position.latitude,
        position.longitude,
      );
      _isSearchMode = false;
      _searchQuery = '';
      notifyListeners();

      // 3. Fetch weather and air quality in parallel to minimize load time
      final results = await Future.wait([
        _weatherService.fetchWeather(position.latitude, position.longitude, _locationName),
        _aqiService.fetchAirQuality(position.latitude, position.longitude),
      ]);

      _weatherData = results[0] as WeatherData;
      _aqiData = results[1] as AirQualityData;
      
      _state = WeatherState.loaded;
      _errorMessage = '';
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _state = WeatherState.error;
    }

    notifyListeners();
  }

  /// Fetch weather data for a searched city/area name
  Future<void> fetchWeatherForCity(String cityName) async {
    if (cityName.trim().isEmpty) return;

    _state = WeatherState.loading;
    _searchQuery = cityName.trim();
    notifyListeners();

    try {
      // 1. Forward geocode: city name → coordinates
      final List<Location> locations = await locationFromAddress(cityName);
      if (locations.isEmpty) {
        throw Exception('Could not find location "$cityName". Try a different name.');
      }

      final Location loc = locations.first;
      final double lat = loc.latitude;
      final double lon = loc.longitude;

      // 2. Reverse geocode to get a clean display name
      _locationName = await LocationService.getCityFromCoordinates(lat, lon);
      _isSearchMode = true;
      notifyListeners();

      // 3. Fetch weather and AQI in parallel
      final results = await Future.wait([
        _weatherService.fetchWeather(lat, lon, _locationName),
        _aqiService.fetchAirQuality(lat, lon),
      ]);

      _weatherData = results[0] as WeatherData;
      _aqiData = results[1] as AirQualityData;

      _state = WeatherState.loaded;
      _errorMessage = '';

      // 4. Save to recent searches
      _addToRecentSearches(cityName.trim());
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _state = WeatherState.error;
    }

    notifyListeners();
  }

  /// Fetch weather data for a specific coordinates pair and display name
  Future<void> fetchWeatherForCoordinates(double lat, double lon, String displayName) async {
    _state = WeatherState.loading;
    _searchQuery = displayName;
    _locationName = displayName;
    _isSearchMode = true;
    notifyListeners();

    try {
      // Fetch weather and AQI in parallel
      final results = await Future.wait([
        _weatherService.fetchWeather(lat, lon, _locationName),
        _aqiService.fetchAirQuality(lat, lon),
      ]);

      _weatherData = results[0] as WeatherData;
      _aqiData = results[1] as AirQualityData;

      _state = WeatherState.loaded;
      _errorMessage = '';

      // Save to recent searches
      _addToRecentSearches(displayName);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _state = WeatherState.error;
    }

    notifyListeners();
  }

  /// Clear search and return to GPS location
  Future<void> clearSearch() async {
    _isSearchMode = false;
    _searchQuery = '';
    await fetchWeatherData();
  }

  /// Add a city to recent searches list (max 10, no duplicates)
  Future<void> _addToRecentSearches(String city) async {
    // Remove if already exists (to re-add at top)
    _recentSearches.remove(city);
    _recentSearches.insert(0, city);

    // Limit to 10 entries
    if (_recentSearches.length > 10) {
      _recentSearches = _recentSearches.sublist(0, 10);
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(Constants.keyRecentSearches, jsonEncode(_recentSearches));
  }

  /// Remove a specific item from recent searches
  Future<void> removeRecentSearch(String city) async {
    _recentSearches.remove(city);
    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(Constants.keyRecentSearches, jsonEncode(_recentSearches));
  }

  /// Clear all recent searches
  Future<void> clearRecentSearches() async {
    _recentSearches.clear();
    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(Constants.keyRecentSearches);
  }
}
