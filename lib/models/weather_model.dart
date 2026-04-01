class WeatherModel {
  final String cityName;
  final double temp;
  final String mainCondition; // e.g., "Clear", "Rain"
  final String description;
  final String icon;
  final double windSpeed;
  final int humidity;

  WeatherModel({
    required this.cityName,
    required this.temp,
    required this.mainCondition,
    required this.description,
    required this.icon,
    required this.windSpeed,
    required this.humidity,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['name'] ?? '',
      temp: (json['main']['temp'] ?? 0).toDouble(),
      mainCondition: json['weather'][0]['main'] ?? '',
      description: json['weather'][0]['description'] ?? '',
      icon: json['weather'][0]['icon'] ?? '',
      windSpeed: (json['wind']['speed'] ?? 0).toDouble(),
      humidity: json['main']['humidity'] ?? 0,
    );
  }
}
