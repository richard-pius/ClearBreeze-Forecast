import 'dart:math';

class AqiCalculator {
  // Interpolation formula:
  // Ip = ((IHi - ILo) / (BPHi - BPLo)) * (Cp - BPLo) + ILo
  static int _interpolate(double cp, double bpMin, double bpMax, double iMin, double iMax) {
    if (bpMax == bpMin) return iMin.round();
    final double result = ((iMax - iMin) / (bpMax - bpMin)) * (cp - bpMin) + iMin;
    return result.round();
  }

  // Calculate PM2.5 AQI
  static int calculatePm25Aqi(double value) {
    // Truncate to one decimal place per EPA guideline
    final double cp = (value * 10).truncateToDouble() / 10.0;

    if (cp <= 12.0) {
      return _interpolate(cp, 0.0, 12.0, 0.0, 50.0);
    } else if (cp <= 35.4) {
      return _interpolate(cp, 12.1, 35.4, 51.0, 100.0);
    } else if (cp <= 55.4) {
      return _interpolate(cp, 35.5, 55.4, 101.0, 150.0);
    } else if (cp <= 150.4) {
      return _interpolate(cp, 55.5, 150.4, 151.0, 200.0);
    } else if (cp <= 250.4) {
      return _interpolate(cp, 150.5, 250.4, 201.0, 300.0);
    } else if (cp <= 350.4) {
      return _interpolate(cp, 250.5, 350.4, 301.0, 400.0);
    } else if (cp <= 500.4) {
      return _interpolate(cp, 350.5, 500.4, 401.0, 500.0);
    } else {
      return 500; // Cap at 500
    }
  }

  // Calculate PM10 AQI
  static int calculatePm10Aqi(double value) {
    // Truncate to integer per EPA guideline
    final double cp = value.truncateToDouble();

    if (cp <= 54.0) {
      return _interpolate(cp, 0.0, 54.0, 0.0, 50.0);
    } else if (cp <= 154.0) {
      return _interpolate(cp, 55.0, 154.0, 51.0, 100.0);
    } else if (cp <= 254.0) {
      return _interpolate(cp, 155.0, 254.0, 101.0, 150.0);
    } else if (cp <= 354.0) {
      return _interpolate(cp, 255.0, 354.0, 151.0, 200.0);
    } else if (cp <= 424.0) {
      return _interpolate(cp, 355.0, 424.0, 201.0, 300.0);
    } else if (cp <= 504.0) {
      return _interpolate(cp, 425.0, 504.0, 301.0, 400.0);
    } else if (cp <= 604.0) {
      return _interpolate(cp, 505.0, 604.0, 401.0, 500.0);
    } else {
      return 500; // Cap at 500
    }
  }

  // Get final AQI from PM2.5 and PM10 concentrations
  static int calculateAqi({double? pm25, double? pm10}) {
    int aqiPm25 = 0;
    int aqiPm10 = 0;

    if (pm25 != null && pm25 >= 0) {
      aqiPm25 = calculatePm25Aqi(pm25);
    }

    if (pm10 != null && pm10 >= 0) {
      aqiPm10 = calculatePm10Aqi(pm10);
    }

    // Standard EPA AQI is the maximum of the calculated sub-indices
    return max(aqiPm25, aqiPm10);
  }

  // Get human readable category and status
  static String getCategory(int aqi) {
    if (aqi <= 50) {
      return 'Good';
    } else if (aqi <= 100) {
      return 'Moderate';
    } else if (aqi <= 150) {
      return 'Unhealthy for Sensitive Groups';
    } else if (aqi <= 200) {
      return 'Unhealthy';
    } else if (aqi <= 300) {
      return 'Very Unhealthy';
    } else {
      return 'Hazardous';
    }
  }
}
