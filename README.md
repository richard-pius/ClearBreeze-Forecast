# ClearBreeze Forecast 💨

ClearBreeze Forecast is a premium, 100% free, and open-source weather and air quality monitoring application built with Flutter and Dart. Designed with a gorgeous theme-aware glassmorphic UI, it delivers real-time meteorological forecasts and local air quality parameters to keep you informed.

---

## ✨ Features

*   **🔍 Matching Similar Cities Search**: Type any city or area name, and the app will query the geocoder to show a list of similar matches worldwide (e.g. *London, Ontario, Canada* or *London, England, United Kingdom*). Tapping any matching city loads the weather directly from coordinates.
*   **🌓 Animated Light/Dark Mode**: A smooth sun/moon rotation and fade toggle changes the interface theme instantly. The selection is saved to persistent storage (`SharedPreferences`).
*   **🌡️ Temperature Unit Toggle**: Instantly switch between Celsius (°C) and Fahrenheit (°F).
*   **💨 Glassmorphic Design**: Clean layouts using glassmorphic frosted cards, animated gauges, loading shimmers, and weather-aware background gradients that change according to current conditions (e.g. clear sky, cloudy, rainy, snow, and night).
*   **📊 Comprehensive Weather Metrics**: Real-time reports for temperature, wind speed and cardinal direction, humidity, barometric pressure, hourly forecasts, and rain probability.
*   **🍃 Air Quality Index (AQI)**: Accurate AQI readings calculated using EPA standards from PM2.5 and PM10 metrics, complete with radial status gauges and a list of nearby monitoring stations.
*   **🗺️ GPS Location Fetching**: One-tap initialization loads weather details from your exact current location.

---

## 🛠️ Project Structure & Tech Stack

*   **Framework**: [Flutter](https://flutter.dev) (Dart SDK)
*   **State Management**: `Provider`
*   **Local Storage**: `SharedPreferences` for user theme preferences and recent searches.
*   **Services**:
    *   **Location**: `Geolocator` (GPS fetching) and `Geocoding` (for coordinates lookup and address formatting).
    *   **Weather API**: [MET Norway Locationforecast 2.0 API](https://api.met.no/weatherapi/locationforecast/2.0/documentation) (requires no keys).
    *   **Air Quality API**: [OpenAQ Platform API v3](https://docs.openaq.org) (uses optional API key, falls back to simulation mode if none is set).

---

## 🚀 Getting Started

### Prerequisites
Make sure you have the following installed on your system:
*   [Flutter SDK](https://docs.flutter.dev/get-started/install) (version `^3.12.0`)
*   [Android Studio](https://developer.android.com/studio) (for Android compilation)
*   [Xcode](https://developer.apple.com/xcode/) (only if compiling for iOS on macOS)

### Installation & Running Locally

1.  **Clone the Repository**:
    ```bash
    git clone https://github.com/richard-pius/ClearBreeze-Forecast.git
    cd ClearBreeze-Forecast
    ```

2.  **Install Dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Run in Debug Mode**:
    Connect a physical device or emulator and run:
    ```bash
    flutter run
    ```

4.  **Build Release APK**:
    ```bash
    flutter build apk --release
    ```
    The compiled package will be located at `build/app/outputs/flutter-apk/app-release.apk`.

---

## 🔑 API Key Configuration (Optional)
The application works in **Demo Mode** using simulated data if no API key is provided. To get real-world Air Quality Index (AQI) values:
1.  Register for a free API key at [OpenAQ Platform](https://explore.openaq.org/register).
2.  Open [lib/config/constants.dart](lib/config/constants.dart).
3.  Replace the `openaqApiKey` placeholder with your key:
    ```dart
    static const String openaqApiKey = 'YOUR_KEY_HERE';
    ```
    *(Note: To keep your keys secure when publishing online, consider loading keys via environment configuration or `--dart-define` variables).*

---

## 🎨 Creative Commons & API Attributions
This project complies with all attribution requirements of public data providers:
*   **Weather Data**: Provided by the **Norwegian Meteorological Institute (MET Norway)** under the [Creative Commons Attribution 4.0 International (CC BY 4.0) License](https://creativecommons.org/licenses/by/4.0/).
*   **Air Quality Data**: Collected from the open-source **OpenAQ Platform** aggregator under their open-data terms.

---

## 👨‍💻 Author
Designed and developed by **[Richard Pius](https://github.com/richard-pius)** as a personal hobby project.

## ⚖️ License & Disclaimer
This project is open-source software. You are free to modify and distribute it.

**Disclaimer**: This app is provided for informational and educational purposes only. Weather and air quality forecasts are fetched from public endpoints and may contain inaccuracies. Use at your own risk.
