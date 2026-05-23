class AirQualityData {
  final int aqi;
  final String category;
  final double? pm25;
  final double? pm10;
  final double? o3;
  final double? no2;
  final double? so2;
  final double? co;
  final String stationName;
  final double? distanceKm;
  final DateTime lastUpdated;

  AirQualityData({
    required this.aqi,
    required this.category,
    this.pm25,
    this.pm10,
    this.o3,
    this.no2,
    this.so2,
    this.co,
    required this.stationName,
    this.distanceKm,
    required this.lastUpdated,
  });

  factory AirQualityData.empty() {
    return AirQualityData(
      aqi: 0,
      category: 'No Data',
      stationName: 'Unknown Station',
      lastUpdated: DateTime.now(),
    );
  }

  bool get isEmpty => aqi == 0 && category == 'No Data';
}
