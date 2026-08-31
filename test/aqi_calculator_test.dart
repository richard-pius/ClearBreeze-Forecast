import 'package:flutter_test/flutter_test.dart';
import 'package:clearbreeze_forecast/services/aqi_calculator.dart';

void main() {
  group('calculateAqi', () {
    test('returns null when neither pollutant is reported', () {
      // Critical: a missing reading must not surface as AQI 0 ("Good").
      expect(AqiCalculator.calculateAqi(pm25: null, pm10: null), isNull);
    });

    test('uses the single reported pollutant', () {
      expect(AqiCalculator.calculateAqi(pm25: 12.0, pm10: null), 50);
      expect(AqiCalculator.calculateAqi(pm25: null, pm10: 54.0), 50);
    });

    test('takes the maximum sub-index when both are reported', () {
      // pm10=154 -> 100, pm25=12 -> 50; EPA takes the worst.
      expect(AqiCalculator.calculateAqi(pm25: 12.0, pm10: 154.0), 100);
    });

    test('distinguishes a genuine zero from missing data', () {
      expect(AqiCalculator.calculateAqi(pm25: 0.0, pm10: null), 0);
    });

    test('caps at 500 for off-scale concentrations', () {
      expect(AqiCalculator.calculateAqi(pm25: 9999.0, pm10: null), 500);
    });
  });

  group('getCategory', () {
    test('maps EPA breakpoints', () {
      expect(AqiCalculator.getCategory(50), 'Good');
      expect(AqiCalculator.getCategory(100), 'Moderate');
      expect(AqiCalculator.getCategory(150), 'Unhealthy for Sensitive Groups');
      expect(AqiCalculator.getCategory(200), 'Unhealthy');
      expect(AqiCalculator.getCategory(300), 'Very Unhealthy');
      expect(AqiCalculator.getCategory(301), 'Hazardous');
    });
  });
}
