import 'package:flutter/material.dart';
import 'package:flutter_weather_app/models/weather_model.dart';
import 'package:flutter_weather_app/models/forecast_model.dart';
import 'package:flutter_weather_app/services/weather_service.dart';
import 'package:flutter_weather_app/utils/weather_utils.dart';
import 'package:flutter_weather_app/widgets/glass_container.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:lottie/lottie.dart';
import 'package:sensors_plus/sensors_plus.dart';

class WeatherPage extends StatefulWidget {
  final String? city;
  final VoidCallback? onAddToFavorites;
  final bool isPreview;

  const WeatherPage({
    super.key,
    this.city,
    this.onAddToFavorites,
    this.isPreview = false,
  });

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final WeatherService _weatherService = WeatherService();
  WeatherModel? _weather;
  ForecastModel? _forecast;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  @override
  void didUpdateWidget(covariant WeatherPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.city != widget.city) {
      _fetchWeather();
    }
  }

  Future<void> _fetchWeather() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final weather = widget.city == null
          ? await _weatherService.getWeatherByLocation()
          : await _weatherService.getWeatherByCity(widget.city!);

      final forecast = widget.city == null
          ? await _weatherService.getForecastByLocation()
          : await _weatherService.getForecastByCity(widget.city!);

      setState(() {
        _weather = weather;
        _forecast = forecast;
        _isLoading = false;
      });
    } catch (e) {
      String errorMessage = e.toString();
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          errorMessage = "Check API Key.";
        } else if (e.response?.statusCode == 404) {
          errorMessage = "City not found.";
        } else if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          errorMessage = "Timeout.";
        } else if (e.type == DioExceptionType.connectionError) {
          errorMessage = "No Internet.";
        }
      }

      if (mounted) {
        setState(() {
          _error = errorMessage.replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // If preview and loaded, show add button overlay
    return Stack(
      children: [
        // Background & Content
        Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: _weather != null
                ? Text(
                    _weather!.cityName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
            centerTitle: true,
            automaticallyImplyLeading: false, // Managed by parent
          ),
          body: Stack(
            children: [
              // 1. Dynamic Background with Parallax
              StreamBuilder<AccelerometerEvent>(
                stream: accelerometerEventStream(),
                builder: (context, snapshot) {
                  double x = 0;
                  double y = 0;
                  if (snapshot.hasData) {
                    x = snapshot.data!.x;
                    y = snapshot.data!.y;
                  }
                  return Transform(
                    transform: Matrix4.translationValues(-x * 2, y * 2, 0),
                    child: Container(
                      width: MediaQuery.of(context).size.width + 40,
                      height: MediaQuery.of(context).size.height + 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: _getBackgroundColors(_weather?.mainCondition),
                        ),
                      ),
                    ),
                  );
                },
              ),

              // 2. Content
              _isLoading
                  ? const Center(
                      child: SpinKitDoubleBounce(
                        color: Colors.white,
                        size: 80.0,
                      ),
                    )
                  : _error != null
                  ? Center(
                      child: GlassContainer(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.redAccent,
                              size: 60,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _error!,
                              style: const TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () => _fetchWeather(),
                              child: const Text("Retry"),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Main Weather Card
                          GlassContainer(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Lottie.network(
                                  WeatherUtils.getLottieAnimation(
                                    _weather?.mainCondition,
                                  ),
                                  height: 150,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      WeatherUtils.getFallbackIcon(
                                        _weather?.mainCondition,
                                      ),
                                      color: Colors.white,
                                      size: 100,
                                    );
                                  },
                                ),
                                Text(
                                  "${_weather!.temp.round()}°",
                                  style: const TextStyle(
                                    fontSize: 80,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  _weather!.mainCondition,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  DateFormat(
                                    'EEEE, d MMM',
                                  ).format(DateTime.now()),
                                  style: const TextStyle(color: Colors.white60),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Smart Suggestion
                          if (_weather != null)
                            GlassContainer(
                              padding: const EdgeInsets.all(15),
                              margin: const EdgeInsets.only(bottom: 20),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.tips_and_updates,
                                    color: Colors.yellowAccent,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _getSmartSuggestion(_weather!),
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Hourly Forecast
                          if (_forecast != null) ...[
                            const Text(
                              "Hourly Forecast",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 150,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _forecast!.list.length > 8
                                    ? 8
                                    : _forecast!.list.length,
                                itemBuilder: (context, index) {
                                  final item = _forecast!.list[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: GlassContainer(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            DateFormat(
                                              'HH:mm',
                                            ).format(item.date),
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12,
                                            ),
                                          ),
                                          Lottie.network(
                                            WeatherUtils.getLottieAnimation(
                                              item.mainCondition,
                                            ),
                                            height: 50,
                                            width: 50,
                                            errorBuilder:
                                                (
                                                  context,
                                                  error,
                                                  stackTrace,
                                                ) => Icon(
                                                  WeatherUtils.getFallbackIcon(
                                                    item.mainCondition,
                                                  ),
                                                  color: Colors.white,
                                                  size: 30,
                                                ),
                                          ),
                                          Text(
                                            "${item.temp.round()}°",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Daily Forecast
                            const Text(
                              "5-Day Forecast",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _getDailyForecasts().length,
                              itemBuilder: (context, index) {
                                final item = _getDailyForecasts()[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: GlassContainer(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 15,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          DateFormat('EEEE').format(item.date),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Lottie.network(
                                              WeatherUtils.getLottieAnimation(
                                                item.mainCondition,
                                              ),
                                              height: 30,
                                              width: 30,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => Icon(
                                                    WeatherUtils.getFallbackIcon(
                                                      item.mainCondition,
                                                    ),
                                                    color: Colors.white,
                                                    size: 20,
                                                  ),
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              "${item.temp.round()}°",
                                              style: const TextStyle(
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Details Grid
                          const Text(
                            "Details",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              _buildDetailItem(
                                Icons.water_drop,
                                "Humidity",
                                "${_weather!.humidity}%",
                              ),
                              _buildDetailItem(
                                Icons.air,
                                "Wind",
                                "${_weather!.windSpeed} m/s",
                              ),
                              _buildDetailItem(
                                Icons.thermostat,
                                "Feels Like",
                                "${_weather!.temp.round()}°",
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
            ],
          ),
        ),

        // Add Button Overlay (if preview)
        if (widget.isPreview && !_isLoading && _error == null)
          Positioned(
            bottom: 30,
            right: 20,
            left: 20,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: widget.onAddToFavorites,
              icon: const Icon(Icons.favorite),
              label: const Text("Add to Favorites"),
            ),
          ),
      ],
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    double width = (MediaQuery.of(context).size.width - 52) / 2;
    return SizedBox(
      width: width,
      child: GlassContainer(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 5),
            Text(
              label,
              style: const TextStyle(color: Colors.white60, fontSize: 12),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Color> _getBackgroundColors(String? condition) {
    if (condition == null) return [Colors.blueGrey, Colors.black];
    switch (condition.toLowerCase()) {
      case 'clear':
        return [Colors.orange, Colors.deepOrange];
      case 'clouds':
      case 'mist':
      case 'fog':
        return [Colors.blueGrey, Colors.grey];
      case 'rain':
      case 'drizzle':
      case 'thunderstorm':
        return [const Color(0xFF1A2344), Colors.black];
      case 'snow':
        return [Colors.lightBlue, Colors.blueGrey];
      default:
        return [Colors.blue, Colors.lightBlueAccent];
    }
  }

  String _getSmartSuggestion(WeatherModel weather) {
    String cond = weather.mainCondition.toLowerCase();
    if (cond.contains('rain') ||
        cond.contains('drizzle') ||
        cond.contains('thunder')) {
      return "Don't forget your umbrella!";
    } else if (cond.contains('snow')) {
      return "Wrap up warm!";
    } else if (cond.contains('clear')) {
      return "Wear sunglasses!";
    } else if (weather.temp < 10) {
      return "Wear a jacket.";
    }
    return "Enjoy the beautiful weather!";
  }

  List<ForecastItem> _getDailyForecasts() {
    if (_forecast == null) return [];
    final Map<String, ForecastItem> daily = {};
    for (var item in _forecast!.list) {
      final dateId = DateFormat('yyyy-MM-dd').format(item.date);
      if (!daily.containsKey(dateId) ||
          (item.date.hour - 12).abs() < (daily[dateId]!.date.hour - 12).abs()) {
        daily[dateId] = item;
      }
    }
    return daily.values.toList()..sort((a, b) => a.date.compareTo(b.date));
  }
}
