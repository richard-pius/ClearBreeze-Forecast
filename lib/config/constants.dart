class Constants {
  // App Config
  static const String appName = 'ClearBreeze Forecast';
  static const String appVersion = '1.0.0';

  // API Endpoints
  // MET Norway Locationforecast 2.0 complete endpoint (provides precipitation probability)
  static const String weatherBaseUrl = 'https://api.met.no/weatherapi/locationforecast/2.0/complete';
  
  // OpenAQ API v3 base URL
  static const String openaqBaseUrl = 'https://api.openaq.org/v3';

  // MANDATORY: Custom User-Agent for MET Norway API
  static const String weatherUserAgent = 'ClearBreezeForecast/1.0 (contact@clearbreeze.com)';

  // OpenAQ API Key Placeholder
  // NOTE: Get a free API key at https://explore.openaq.org/register
  static const String openaqApiKey = 'YOUR_OPENAQ_API_KEY_HERE';

  // OpenAQ location search radius in meters (Max: 25000)
  static const int openaqSearchRadius = 25000;

  // Preferences Keys
  static const String keyTempUnit = 'temp_unit'; // 'C' or 'F'
  static const String keyThemeMode = 'theme_mode'; // 'dark' or 'light'
  static const String keyRecentSearches = 'recent_searches';
  static const String keyCachedWeatherData = 'cached_weather_data';
  static const String keyCachedAqiData = 'cached_aqi_data';
  static const String keyCacheTime = 'cache_time';
}
