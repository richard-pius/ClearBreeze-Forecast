/// Why air quality could not be shown for a location.
///
/// Each case carries user-facing copy so the UI never has to guess at the
/// wording, and so we can explain *why* the data is missing rather than
/// showing a generic blank state.
enum AqiUnavailableReason {
  /// The build has no OpenAQ API key compiled in.
  notConfigured,

  /// No monitoring station within the search radius.
  noStationNearby,

  /// A station was found, but it reported no PM2.5 or PM10 readings, which
  /// are the two parameters the US EPA AQI formula requires.
  noMeasurements,

  /// Network or API error while contacting OpenAQ.
  fetchFailed;

  String get title {
    switch (this) {
      case AqiUnavailableReason.notConfigured:
        return 'Air Quality Not Configured';
      case AqiUnavailableReason.noStationNearby:
        return 'No Monitoring Stations Nearby';
      case AqiUnavailableReason.noMeasurements:
        return 'No Air Quality Readings Available';
      case AqiUnavailableReason.fetchFailed:
        return 'Air Quality Data Unavailable';
    }
  }

  String get message {
    switch (this) {
      case AqiUnavailableReason.notConfigured:
        return 'This build has no OpenAQ API key, so live air quality data '
            'cannot be retrieved.';
      case AqiUnavailableReason.noStationNearby:
        return 'No air quality monitoring station reported data within 25 km '
            'of this location.';
      case AqiUnavailableReason.noMeasurements:
        return 'The nearest station is not currently reporting PM2.5 or PM10, '
            'which are required to calculate an AQI value.';
      case AqiUnavailableReason.fetchFailed:
        return 'Could not reach the air quality service. Pull down to refresh '
            'and try again.';
    }
  }
}

/// Air quality snapshot for one location.
///
/// [aqi] is null whenever a real index could not be computed from live
/// measurements — in that case [unavailableReason] explains why. The app
/// never substitutes simulated or estimated values; if OpenAQ did not report
/// it, the UI says so.
class AirQualityData {
  final int? aqi;
  final String? category;
  final double? pm25;
  final double? pm10;
  final double? o3;
  final double? no2;
  final double? so2;
  final double? co;
  final String? stationName;
  final double? distanceKm;
  final DateTime? lastUpdated;
  final AqiUnavailableReason? unavailableReason;

  const AirQualityData({
    this.aqi,
    this.category,
    this.pm25,
    this.pm10,
    this.o3,
    this.no2,
    this.so2,
    this.co,
    this.stationName,
    this.distanceKm,
    this.lastUpdated,
    this.unavailableReason,
  });

  /// No usable air quality data for this location.
  factory AirQualityData.unavailable(
    AqiUnavailableReason reason, {
    String? stationName,
    double? distanceKm,
    double? pm25,
    double? pm10,
    double? o3,
    double? no2,
    double? so2,
    double? co,
    DateTime? lastUpdated,
  }) {
    return AirQualityData(
      aqi: null,
      category: null,
      pm25: pm25,
      pm10: pm10,
      o3: o3,
      no2: no2,
      so2: so2,
      co: co,
      stationName: stationName,
      distanceKm: distanceKm,
      lastUpdated: lastUpdated,
      unavailableReason: reason,
    );
  }

  /// True when a real AQI value was computed from live measurements.
  bool get hasData => aqi != null && unavailableReason == null;
}
