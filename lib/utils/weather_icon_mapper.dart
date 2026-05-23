import 'package:flutter/material.dart';

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
    } else if (code.contains('rainandthunder') || code.contains('heavyrainandthunder')) {
      return '⛈️';
    } else if (code.contains('heavyrain')) {
      return '🌧️';
    } else if (code.contains('lightrain') || code.contains('rain')) {
      return '🌧️';
    } else if (code.contains('snowshowers') && code.contains('thunder')) {
      return '⛈️';
    } else if (code.contains('snowshowers')) {
      return '🌨️';
    } else if (code.contains('snowandthunder') || code.contains('heavysnowandthunder')) {
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

  /// Maps MET Norway symbol_code to Flutter IconData (Material design icons)
  static IconData getIconData(String symbolCode) {
    final String code = symbolCode.toLowerCase();

    if (code.contains('clearsky')) {
      return code.contains('night') ? Icons.brightness_3 : Icons.wb_sunny;
    } else if (code.contains('fair')) {
      return code.contains('night') ? Icons.nights_stay : Icons.wb_cloudy_outlined;
    } else if (code.contains('partlycloudy')) {
      return Icons.cloud_queue;
    } else if (code.contains('cloudy')) {
      return Icons.cloud;
    } else if (code.contains('thunder')) {
      return Icons.thunderstorm;
    } else if (code.contains('rain')) {
      return Icons.grain;
    } else if (code.contains('snow')) {
      return Icons.ac_unit;
    } else if (code.contains('sleet')) {
      return Icons.ac_unit;
    } else if (code.contains('fog')) {
      return Icons.cloud_off;
    }

    return Icons.wb_sunny;
  }

  /// Maps MET Norway symbol_code to human-readable description
  static String getConditionDescription(String symbolCode) {
    final String code = symbolCode.toLowerCase();
    
    // Replace underscores with spaces and capitalize
    String formatted = code
        .replaceAll('_day', '')
        .replaceAll('_night', '')
        .replaceAll('_polartwilight', '');
        
    if (formatted == 'clearsky') return 'Clear Sky';
    if (formatted == 'fair') return 'Fair Weather';
    if (formatted == 'partlycloudy') return 'Partly Cloudy';
    if (formatted == 'cloudy') return 'Cloudy';
    if (formatted == 'lightrain') return 'Light Rain';
    if (formatted == 'rain') return 'Rain';
    if (formatted == 'heavyrain') return 'Heavy Rain';
    if (formatted == 'lightrainshowers') return 'Light Rain Showers';
    if (formatted == 'rainshowers') return 'Rain Showers';
    if (formatted == 'heavyrainshowers') return 'Heavy Rain Showers';
    if (formatted == 'lightsnow') return 'Light Snow';
    if (formatted == 'snow') return 'Snow';
    if (formatted == 'heavysnow') return 'Heavy Snow';
    if (formatted == 'lightsleet') return 'Light Sleet';
    if (formatted == 'sleet') return 'Sleet';
    if (formatted == 'heavysleet') return 'Heavy Sleet';
    if (formatted == 'rainandthunder') return 'Rain and Thunder';
    if (formatted == 'heavyrainandthunder') return 'Heavy Rain and Thunder';
    if (formatted == 'snowandthunder') return 'Snow and Thunder';
    if (formatted == 'lightrainshowersandthunder') return 'Light Rain Showers and Thunder';
    if (formatted == 'rainshowersandthunder') return 'Rain Showers and Thunder';
    if (formatted == 'heavyrainshowersandthunder') return 'Heavy Rain Showers and Thunder';
    if (formatted == 'fog') return 'Foggy';

    return formatted.toUpperCase();
  }

  /// Returns custom linear gradient based on the symbol_code and day/night
  static List<Color> getGradient(String symbolCode) {
    final String code = symbolCode.toLowerCase();
    
    if (code.contains('night')) {
      return [
        const Color(0xFF0F172A), // Slate 900
        const Color(0xFF020617), // Slate 950
      ];
    }

    if (code.contains('clearsky') || code.contains('fair')) {
      return [
        const Color(0xFF0284C7), // Sky 600
        const Color(0xFF0369A1), // Sky 700
      ];
    }

    if (code.contains('cloudy') || code.contains('partlycloudy')) {
      return [
        const Color(0xFF334155), // Slate 700
        const Color(0xFF1E293B), // Slate 800
      ];
    }

    if (code.contains('rain') || code.contains('thunder')) {
      return [
        const Color(0xFF1E293B), // Slate 800
        const Color(0xFF0F172A), // Slate 900
      ];
    }

    if (code.contains('snow') || code.contains('sleet')) {
      return [
        const Color(0xFF475569), // Slate 600
        const Color(0xFF334155), // Slate 700
      ];
    }

    return [
      const Color(0xFF0284C7), // Default Day Sky
      const Color(0xFF0A1628), // Deep Navy
    ];
  }

  /// Returns light-mode gradient based on symbol_code
  static List<Color> getGradientLight(String symbolCode) {
    final String code = symbolCode.toLowerCase();

    if (code.contains('night')) {
      return [
        const Color(0xFF1E293B), // Slate 800
        const Color(0xFF334155), // Slate 700
      ];
    }

    if (code.contains('clearsky') || code.contains('fair')) {
      return [
        const Color(0xFF7DD3FC), // Sky 300
        const Color(0xFF38BDF8), // Sky 400
      ];
    }

    if (code.contains('cloudy') || code.contains('partlycloudy')) {
      return [
        const Color(0xFFCBD5E1), // Slate 300
        const Color(0xFF94A3B8), // Slate 400
      ];
    }

    if (code.contains('rain') || code.contains('thunder')) {
      return [
        const Color(0xFF94A3B8), // Slate 400
        const Color(0xFF64748B), // Slate 500
      ];
    }

    if (code.contains('snow') || code.contains('sleet')) {
      return [
        const Color(0xFFE2E8F0), // Slate 200
        const Color(0xFFCBD5E1), // Slate 300
      ];
    }

    return [
      const Color(0xFF7DD3FC), // Default Light Sky
      const Color(0xFF38BDF8), // Sky 400
    ];
  }
}

