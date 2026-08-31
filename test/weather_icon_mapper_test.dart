import 'package:flutter_test/flutter_test.dart';
import 'package:clearbreeze_forecast/utils/weather_icon_mapper.dart';

void main() {
  group('getConditionDescription', () {
    test('handles plain conditions with day/night suffixes', () {
      expect(WeatherIconMapper.getConditionDescription('clearsky_day'),
          'Clear Sky');
      expect(WeatherIconMapper.getConditionDescription('clearsky_night'),
          'Clear Sky');
      expect(
          WeatherIconMapper.getConditionDescription('fair_polartwilight'),
          'Fair Weather');
      expect(WeatherIconMapper.getConditionDescription('partlycloudy_day'),
          'Partly Cloudy');
      expect(WeatherIconMapper.getConditionDescription('cloudy'), 'Cloudy');
      expect(WeatherIconMapper.getConditionDescription('fog'), 'Foggy');
    });

    test('handles intensity prefixes', () {
      expect(WeatherIconMapper.getConditionDescription('lightrain'),
          'Light Rain');
      expect(WeatherIconMapper.getConditionDescription('heavysnow'),
          'Heavy Snow');
      expect(WeatherIconMapper.getConditionDescription('sleet'), 'Sleet');
    });

    test('handles showers and thunder modifiers', () {
      expect(WeatherIconMapper.getConditionDescription('rainshowers_day'),
          'Rain Showers');
      expect(WeatherIconMapper.getConditionDescription('rainandthunder'),
          'Rain and Thunder');
      expect(
          WeatherIconMapper.getConditionDescription(
              'heavyrainshowersandthunder_day'),
          'Heavy Rain Showers and Thunder');
    });

    test('handles codes the old lookup table missed', () {
      expect(WeatherIconMapper.getConditionDescription('sleetshowers_day'),
          'Sleet Showers');
      expect(
          WeatherIconMapper.getConditionDescription(
              'heavysleetshowersandthunder_night'),
          'Heavy Sleet Showers and Thunder');
      expect(
          WeatherIconMapper.getConditionDescription('lightsnowshowers_day'),
          'Light Snow Showers');
      expect(WeatherIconMapper.getConditionDescription('lightsleetandthunder'),
          'Light Sleet and Thunder');
    });

    test('degrades gracefully on an unknown code', () {
      expect(WeatherIconMapper.getConditionDescription('asteroidstrike'),
          'Unavailable');
      expect(WeatherIconMapper.getConditionDescription(''), 'Unknown');
    });
  });
}
