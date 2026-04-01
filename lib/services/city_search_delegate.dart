import 'package:flutter/material.dart';
import 'package:flutter_weather_app/services/weather_service.dart';

class CitySearchDelegate extends SearchDelegate<String?> {
  final WeatherService _weatherService = WeatherService();

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  // Display suggestions while typing
  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.length < 3) {
      return const Center(child: Text("Type at least 3 letters..."));
    }

    return FutureBuilder<List<String>>(
      future: _weatherService.getCitySuggestions(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No cities found"));
        }

        final suggestions = snapshot.data!;
        return ListView.builder(
          itemCount: suggestions.length,
          itemBuilder: (context, index) {
            final city = suggestions[index];
            return ListTile(
              title: Text(city),
              onTap: () => close(
                context,
                city.split(',').first,
              ), // Return just city name
            );
          },
        );
      },
    );
  }

  // When user hits "enter" without selecting a suggestion
  @override
  Widget buildResults(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () => close(context, query),
        child: Text("Search for '$query'"),
      ),
    );
  }
}
