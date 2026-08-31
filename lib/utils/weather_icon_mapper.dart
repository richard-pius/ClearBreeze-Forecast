class WeatherIconMapper {
  /// Maps MET Norway symbol_code to an Emoji representing the condition
  static String getEmoji(String symbolCode) {
    // Standardize symbolCode by removing day/night suffixes for general classification if needed
    final String code = symbolCode.toLowerCase();

    if (code.contains('clearsky')) {
      return code.contains('night') ? '🌙' : '☀️';
    } else if (code.contains('fair')) {
      return code.contains('night') ? '🌙' : '🌤️';
    } else if (code.contains('partlycloudy')) {
      return '⛅';
    } else if (code.contains('cloudy')) {
      return '☁️';
    } else if (code.contains('rainshowers') && code.contains('thunder')) {
      return '⛈️';
    } else if (code.contains('rainshowers')) {
      return '🌦️';
    } else if (code.contains('rainandthunder') ||
        code.contains('heavyrainandthunder')) {
      return '⛈️';
    } else if (code.contains('heavyrain')) {
      return '🌧️';
    } else if (code.contains('lightrain') || code.contains('rain')) {
      return '🌧️';
    } else if (code.contains('snowshowers') && code.contains('thunder')) {
      return '⛈️';
    } else if (code.contains('snowshowers')) {
      return '🌨️';
    } else if (code.contains('snowandthunder') ||
        code.contains('heavysnowandthunder')) {
      return '⛈️';
    } else if (code.contains('heavysnow')) {
      return '❄️';
    } else if (code.contains('lightsnow') || code.contains('snow')) {
      return '🌨️';
    } else if (code.contains('sleet')) {
      return '🌨️';
    } else if (code.contains('fog')) {
      return '🌫️';
    }

    return '☀️'; // default fallback
  }

  /// Base weather terms in the MET Norway symbol vocabulary.
  static const Map<String, String> _baseConditions = {
    'clearsky': 'Clear Sky',
    'fair': 'Fair Weather',
    'partlycloudy': 'Partly Cloudy',
    'cloudy': 'Cloudy',
    'fog': 'Foggy',
    'rain': 'Rain',
    'snow': 'Snow',
    'sleet': 'Sleet',
  };

  /// Converts a MET Norway symbol_code into human-readable text.
  ///
  /// MET codes follow a consistent grammar:
  /// `[light|heavy]<base>[showers][andthunder]_[day|night|polartwilight]`,
  /// which yields roughly 50 permutations. Rather than enumerate them all,
  /// this decomposes the code so every valid combination renders correctly —
  /// including uncommon ones like `heavysleetshowersandthunder`.
  static String getConditionDescription(String symbolCode) {
    String code = symbolCode.toLowerCase();

    // Strip the time-of-day suffix.
    for (final suffix in const ['_day', '_night', '_polartwilight']) {
      code = code.replaceAll(suffix, '');
    }

    // Peel off the modifiers, outermost first.
    final bool hasThunder = code.endsWith('andthunder');
    if (hasThunder) {
      code = code.substring(0, code.length - 'andthunder'.length);
    }

    final bool isShowers = code.endsWith('showers');
    if (isShowers) {
      code = code.substring(0, code.length - 'showers'.length);
    }

    String? intensity;
    if (code.startsWith('light')) {
      intensity = 'Light';
      code = code.substring('light'.length);
    } else if (code.startsWith('heavy')) {
      intensity = 'Heavy';
      code = code.substring('heavy'.length);
    }

    final String? base = _baseConditions[code];
    if (base == null) {
      // Unknown code — fall back to something readable rather than shouting
      // the raw identifier at the user.
      return symbolCode.isEmpty ? 'Unknown' : 'Unavailable';
    }

    final StringBuffer out = StringBuffer();
    if (intensity != null) out.write('$intensity ');
    out.write(base);
    if (isShowers) out.write(' Showers');
    if (hasThunder) out.write(' and Thunder');

    return out.toString();
  }
}
