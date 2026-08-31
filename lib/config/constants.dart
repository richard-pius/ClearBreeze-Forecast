class Constants {
  // App Config
  static const String appVersion = '1.3.0';

  // API Endpoints
  // MET Norway Locationforecast 2.0 complete endpoint (provides precipitation probability)
  static const String weatherBaseUrl =
      'https://api.met.no/weatherapi/locationforecast/2.0/complete';

  // OpenAQ API v3 base URL
  static const String openaqBaseUrl = 'https://api.openaq.org/v3';

  // MANDATORY: identifying User-Agent for the MET Norway API, per their
  // terms of service. Kept in sync with [appVersion] so MET can correlate
  // traffic with a specific release.
  static const String weatherUserAgent =
      'ClearBreezeForecast/$appVersion (contact@clearbreeze.com)';

  // OpenAQ API Key — loaded from --dart-define at build time for security.
  // To build: flutter run --dart-define=OPENAQ_API_KEY=your_key_here
  // Falls back to empty string if not provided.
  static const String openaqApiKey = String.fromEnvironment(
    'OPENAQ_API_KEY',
    defaultValue: '',
  );

  // OpenAQ location search radius in meters (Max: 25000)
  static const int openaqSearchRadius = 25000;

  // Preferences Keys
  static const String keyTempUnit = 'temp_unit'; // 'C' or 'F'
  static const String keyThemeMode = 'theme_mode'; // 'dark' or 'light'
  static const String keyRecentSearches = 'recent_searches';
}
