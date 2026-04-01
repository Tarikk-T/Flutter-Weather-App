class ForecastModel {
  final List<ForecastItem> list;
  final City city;

  ForecastModel({required this.list, required this.city});

  factory ForecastModel.fromJson(Map<String, dynamic> json) {
    return ForecastModel(
      list: (json['list'] as List)
          .map((i) => ForecastItem.fromJson(i))
          .toList(),
      city: City.fromJson(json['city']),
    );
  }
}

class ForecastItem {
  final int dt;
  final double temp;
  final String mainCondition;
  final String icon;
  final String dtTxt;

  ForecastItem({
    required this.dt,
    required this.temp,
    required this.mainCondition,
    required this.icon,
    required this.dtTxt,
  });

  factory ForecastItem.fromJson(Map<String, dynamic> json) {
    return ForecastItem(
      dt: json['dt'],
      temp: (json['main']['temp'] ?? 0).toDouble(),
      mainCondition: json['weather'][0]['main'] ?? '',
      icon: json['weather'][0]['icon'] ?? '',
      dtTxt: json['dt_txt'] ?? '',
    );
  }

  DateTime get date => DateTime.fromMillisecondsSinceEpoch(dt * 1000);
}

class City {
  final String name;
  final int sunrise;
  final int sunset;

  City({required this.name, required this.sunrise, required this.sunset});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      name: json['name'],
      sunrise: json['sunrise'],
      sunset: json['sunset'],
    );
  }
}
