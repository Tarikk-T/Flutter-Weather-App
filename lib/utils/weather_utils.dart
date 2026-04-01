import 'package:flutter/material.dart';

class WeatherUtils {
  static String getLottieAnimation(String? condition) {
    if (condition == null) {
      return 'https://lottie.host/8a4293e5-857c-48c9-9407-7e235061618c/1X1s3r4E1f.json'; // Default
    }

    // Using new stable community URLs (or placeholders that work)
    switch (condition.toLowerCase()) {
      case 'clouds':
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return 'https://lottie.host/02005477-96a1-4389-b541-4775d714397f/K1z0Q0C6a8.json'; // Cloudy
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return 'https://lottie.host/bf3bd463-7c70-4960-928d-29c8942b0833/1X1s3r4E1f.json'; // Rain
      case 'thunderstorm':
        return 'https://lottie.host/6a56b46b-6750-4217-a060-39958744040a/D6s2s1s1s2.json'; // Thunder
      case 'snow':
        // Updated Snow URL
        return 'https://lottie.host/5a56b46b-6750-4217-a060-39958744040a/D6s2s1s1s2.json';
      case 'clear':
        // Updated Sunny URL (verified placeholder or finding new one)
        return 'https://assets9.lottiefiles.com/packages/lf20_t9ry353e.json';
      default:
        return 'https://assets9.lottiefiles.com/packages/lf20_t9ry353e.json'; // Sunny
    }
  }

  // Fallback Icon if Lottie fails
  static IconData getFallbackIcon(String? condition) {
    if (condition == null) return Icons.sunny;
    switch (condition.toLowerCase()) {
      case 'clouds':
      case 'mist':
      case 'fog':
        return Icons.cloud;
      case 'rain':
      case 'drizzle':
        return Icons.umbrella;
      case 'thunderstorm':
        return Icons.flash_on;
      case 'snow':
        return Icons.ac_unit;
      case 'clear':
        return Icons.sunny;
      default:
        return Icons.sunny;
    }
  }
}
