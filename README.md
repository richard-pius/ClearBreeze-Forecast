# ClearBreeze Forecast 💨

ClearBreeze Forecast is a premium, 100% free, and open-source weather and air quality monitoring application built with Flutter and Dart. Designed with a gorgeous theme-aware glassmorphic UI and time-of-day adaptive backgrounds, it delivers real-time meteorological forecasts and local air quality parameters to keep you informed.

---

## ✨ Features

*   **🌅 Time-of-Day Adaptive Background**: The app background dynamically shifts based on the actual time of day — dawn, morning, afternoon, golden hour, dusk, and night — each with handcrafted gradient palettes for both light and dark themes. Weather conditions (rain, snow, fog, clouds) overlay on top for an immersive, living atmosphere.
*   **🔍 Matching Similar Cities Search**: Type any city or area name, and the app will query the geocoder to show a list of similar matches worldwide (e.g. *London, Ontario, Canada* or *London, England, United Kingdom*). Tapping any matching city loads the weather directly from coordinates.
*   **🌓 Animated Light/Dark Mode**: A smooth sun/moon rotation and fade toggle changes the interface theme instantly. Both themes are carefully tuned for eye-friendly readability. The selection is saved to persistent storage (`SharedPreferences`).
*   **🌡️ Temperature Unit Toggle**: Instantly switch between Celsius (°C) and Fahrenheit (°F).
*   **💨 Glassmorphic Design**: Clean layouts using glassmorphic frosted cards with optimised contrast ratios, animated gauges, loading shimmers, and weather-aware styling that adapts to current conditions.
*   **🌧️ Smart Rain Probability**: Intelligent precipitation estimation that works globally — when the API doesn't provide explicit probability data (outside Nordic regions), the app derives accurate estimates from weather symbol codes and precipitation amounts.
*   **📊 Comprehensive Weather Metrics**: Real-time reports for temperature, feels-like temperature, wind speed and cardinal direction, humidity, barometric pressure, hourly forecasts, and rain probability with a visual progress bar.
*   **🍃 Air Quality Index (AQI)**: Accurate AQI readings calculated using EPA standards from PM2.5 and PM10 metrics, complete with animated radial gauges and nearby monitoring station info.
*   **🗺️ GPS Location Fetching**: One-tap initialisation loads weather details from your exact current location.

---

## 🛠️ Project Structure & Tech Stack

*   **Framework**: [Flutter](https://flutter.dev) (Dart SDK)
*   **State Management**: `Provider`
*   **Local Storage**: `SharedPreferences` for user theme preferences and recent searches.
*   **Services**:
    *   **Location**: `Geolocator` (GPS fetching) and `Geocoding` (for coordinates lookup and address formatting).
    *   **Weather API**: [MET Norway Locationforecast 2.0 API](https://api.met.no/weatherapi/locationforecast/2.0/documentation) (requires no keys).
    *   **Air Quality API**: [OpenAQ Platform API v3](https://docs.openaq.org) (requires a free API key; without one the app clearly reports air quality as unavailable rather than showing placeholder values).

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

## 🔑 API Key Configuration
Weather data needs no key. Air quality requires a free OpenAQ key — **without it the Air Quality card honestly reports that data is unavailable; the app never displays simulated or placeholder readings.**

1.  Register for a free API key at [OpenAQ Platform](https://explore.openaq.org/register).
2.  Pass the key at build time via `--dart-define` (it is read by `Constants.openaqApiKey`, so it is never committed to source):
    ```bash
    flutter run --dart-define=OPENAQ_API_KEY=your_key_here
    ```
    ```bash
    flutter build apk --release --dart-define=OPENAQ_API_KEY=your_key_here
    ```

### Data availability policy
Every value on screen comes from a live API response. Where a provider does not report a metric for a given location, the UI states that explicitly instead of substituting a default:

*   **Wind, humidity, pressure** — shown as *"Not available"* when MET Norway omits the field.
*   **Rain probability** — MET Norway only publishes `probability_of_precipitation` for the Nordic region. Elsewhere the card explains this rather than estimating a percentage.
*   **Air Quality Index** — shown only when a nearby station reports PM2.5 or PM10. Otherwise the card names the reason: no API key, no station within 25 km, no PM readings at the station, or a failed request.

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
