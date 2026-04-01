import 'package:flutter/material.dart';
import 'package:flutter_weather_app/widgets/weather_page.dart';
import 'package:flutter_weather_app/screens/city_list_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  List<String> _cities = []; // Favorites list
  bool _isLoadingPrefs = true;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  Future<void> _loadCities() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _cities = prefs.getStringList('favorites') ?? [];
      // If list is empty, default to Antalya as per requirement.
      if (_cities.isEmpty) {
        _cities = ['Antalya'];
        prefs.setStringList('favorites', _cities); // Persist default
      }
      _isLoadingPrefs = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingPrefs) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _cities.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return WeatherPage(city: _cities[index]);
            },
          ),
          // Menu Button to Open City List
          Positioned(
            top: 50,
            right: 20,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.list, color: Colors.white, size: 30),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CityListScreen(
                        onCitySelected: (index) {
                          // Refresh checks if list changed (deleted items)
                          _loadCities().then((_) {
                            if (index < _cities.length) {
                              _pageController.jumpToPage(index);
                            }
                          });
                        },
                      ),
                    ),
                  ).then((_) => _loadCities()); // Refresh when returning
                },
                tooltip: "Manage Cities",
              ),
            ),
          ),
          // Simple Indicator
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_cities.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 12 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Colors.white
                        : Colors.white.withAlpha(100),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
