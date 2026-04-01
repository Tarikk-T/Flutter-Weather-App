import 'package:flutter/material.dart';
import 'package:flutter_weather_app/services/city_search_delegate.dart';
import 'package:flutter_weather_app/utils/weather_utils.dart';
import 'package:flutter_weather_app/widgets/glass_container.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_weather_app/services/weather_service.dart';
import 'package:flutter_weather_app/models/weather_model.dart';

class CityListScreen extends StatefulWidget {
  final Function(int) onCitySelected; // Callback to jump to page
  const CityListScreen({super.key, required this.onCitySelected});

  @override
  State<CityListScreen> createState() => _CityListScreenState();
}

class _CityListScreenState extends State<CityListScreen> {
  List<String> _cities = [];
  final Map<String, WeatherModel?> _weatherCache = {};
  final WeatherService _weatherService = WeatherService();

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  Future<void> _loadCities() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _cities = prefs.getStringList('favorites') ?? ['Antalya'];
    });
    // Fetch basic weather for each city
    for (var city in _cities) {
      _fetchWeatherForList(city);
    }
  }

  Future<void> _fetchWeatherForList(String city) async {
    try {
      final weather = await _weatherService.getWeatherByCity(city);
      if (mounted) {
        setState(() {
          _weatherCache[city] = weather;
        });
      }
    } catch (e) {
      // Ignore errors for list view preview
    }
  }

  Future<void> _addCity() async {
    final city = await showSearch(
      context: context,
      delegate: CitySearchDelegate(),
    );

    if (city != null && city.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        if (!_cities.contains(city)) {
          _cities.add(city);
          prefs.setStringList('favorites', _cities);
          _fetchWeatherForList(city); // Fetch new city weather
        }
      });
    }
  }

  Future<void> _deleteCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _cities.remove(city);
      prefs.setStringList('favorites', _cities);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Weather",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.white),
            onPressed: _addCity,
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _cities.length,
        itemBuilder: (context, index) {
          final city = _cities[index];
          final weather = _weatherCache[city];

          return Dismissible(
            key: Key(city),
            direction: DismissDirection.endToStart,
            background: Container(
              margin: const EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (direction) => _deleteCity(city),
            child: GestureDetector(
              onTap: () {
                widget.onCitySelected(index);
                Navigator.pop(context);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 15),
                height: 100,
                child: GlassContainer(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            city, // City Name
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (weather != null)
                            Text(
                              weather.mainCondition,
                              style: const TextStyle(color: Colors.white70),
                            ),
                        ],
                      ),
                      if (weather != null)
                        Row(
                          children: [
                            Text(
                              "${weather.temp.round()}°",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Miniature Icon
                            Icon(
                              WeatherUtils.getFallbackIcon(
                                weather.mainCondition,
                              ),
                              color: Colors.white,
                            ),
                          ],
                        )
                      else
                        const CircularProgressIndicator(color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
