import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_weather_app/models/weather_model.dart';
import 'package:flutter_weather_app/models/forecast_model.dart';
import 'package:flutter_weather_app/utils/consts.dart';

class WeatherService {
  final Dio _dio = Dio();

  Future<Position> getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );

    return await Geolocator.getCurrentPosition(
      locationSettings: locationSettings,
    );
  }

  Future<WeatherModel> getWeatherByLocation() async {
    try {
      Position position = await getCurrentLocation();
      final response = await _dio.get(
        '${Consts.baseUrl}?lat=${position.latitude}&lon=${position.longitude}&appid=${Consts.openWeatherApiKey}&units=metric',
      );
      if (response.statusCode == 200) {
        return WeatherModel.fromJson(response.data);
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      throw Exception('Error fetching weather: $e');
    }
  }

  Future<WeatherModel> getWeatherByCity(String cityName) async {
    try {
      final response = await _dio.get(
        '${Consts.baseUrl}?q=$cityName&appid=${Consts.openWeatherApiKey}&units=metric',
      );
      if (response.statusCode == 200) {
        return WeatherModel.fromJson(response.data);
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      throw Exception('Error fetching weather: $e');
    }
  }

  Future<ForecastModel> getForecastByLocation() async {
    try {
      Position position = await getCurrentLocation();
      final response = await _dio.get(
        'https://api.openweathermap.org/data/2.5/forecast?lat=${position.latitude}&lon=${position.longitude}&appid=${Consts.openWeatherApiKey}&units=metric',
      );
      if (response.statusCode == 200) {
        return ForecastModel.fromJson(response.data);
      } else {
        throw Exception('Failed to load forecast data');
      }
    } catch (e) {
      throw Exception('Error fetching forecast: $e');
    }
  }

  Future<ForecastModel> getForecastByCity(String cityName) async {
    try {
      final response = await _dio.get(
        'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&appid=${Consts.openWeatherApiKey}&units=metric',
      );
      if (response.statusCode == 200) {
        return ForecastModel.fromJson(response.data);
      } else {
        throw Exception('Failed to load forecast data');
      }
    } catch (e) {
      throw Exception('Error fetching forecast: $e');
    }
  }

  Future<List<String>> getCitySuggestions(String query) async {
    try {
      final response = await _dio.get(
        'http://api.openweathermap.org/geo/1.0/direct?q=$query&limit=5&appid=${Consts.openWeatherApiKey}',
      );
      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map<String>((json) {
          final name = json['name'];
          final country = json['country'];
          return "$name, $country";
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}
