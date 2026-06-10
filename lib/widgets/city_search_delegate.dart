import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../services/location_service.dart';

class CitySearchDelegate extends SearchDelegate<String> {
  @override
  String get searchFieldLabel => 'Search city or area...';

  @override
  ThemeData appBarTheme(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : const Color(0xFF1E293B),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(
          color: isDark ? Colors.white54 : const Color(0xFF64748B),
          fontSize: 16,
        ),
        border: InputBorder.none,
      ),
      textTheme: theme.textTheme.copyWith(
        titleLarge: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF1E293B),
          fontSize: 16,
        ),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color iconColor = isDark ? Colors.white : const Color(0xFF1E293B);

    return [
      if (query.isNotEmpty)
        IconButton(
          icon: Icon(Icons.clear_rounded, color: iconColor),
          tooltip: 'Clear',
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
      IconButton(
        icon: Icon(Icons.search_rounded, color: iconColor),
        tooltip: 'Search',
        onPressed: () {
          if (query.trim().isNotEmpty) {
            showResults(context);
          }
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color iconColor = isDark ? Colors.white : const Color(0xFF1E293B);

    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: const AlwaysStoppedAnimation(1.0),
        color: iconColor,
      ),
      onPressed: () => close(context, ''),
    );
  }

  Widget _buildSimilarCitiesView(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final Color textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final Color subtitleColor = isDark ? Colors.white54 : const Color(0xFF475569);
    final Color dividerColor = isDark ? Colors.white10 : Colors.black12;

    return Container(
      color: bgColor,
      child: FutureBuilder<List<Map<String, dynamic>>>(
        key: ValueKey(query), // Force new future when query changes
        future: LocationService.getSimilarCities(query),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blueAccent),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Error searching for "$query"',
                      style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString().replaceAll('Exception: ', ''),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: subtitleColor, fontSize: 13),
                    ),
                  ],
                ),
              ),
            );
          }

          final List<Map<String, dynamic>> cities = snapshot.data ?? [];

          if (cities.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_off_rounded, color: subtitleColor.withValues(alpha: 0.5), size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'No matching cities found for "$query"',
                      style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Try checking the spelling or typing another name.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: subtitleColor, fontSize: 13),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Text(
                  'Matching Locations',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: subtitleColor,
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: cities.length,
                  separatorBuilder: (_, _) => Divider(
                    height: 1,
                    color: dividerColor,
                    indent: 60,
                  ),
                  itemBuilder: (context, index) {
                    final Map<String, dynamic> city = cities[index];
                    return ListTile(
                      leading: const Icon(
                        Icons.location_city_rounded,
                        color: Colors.blueAccent,
                      ),
                      title: Text(
                        city['name'] ?? '',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        'Lat: ${city['latitude'].toStringAsFixed(3)}°, Lon: ${city['longitude'].toStringAsFixed(3)}°',
                        style: TextStyle(
                          color: subtitleColor.withValues(alpha: 0.8),
                          fontSize: 11,
                        ),
                      ),
                      onTap: () {
                        // Tapped city, load weather directly for coordinates and display name
                        final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
                        weatherProvider.fetchWeatherForCoordinates(
                          city['latitude'] as double,
                          city['longitude'] as double,
                          city['name'] as String,
                        );
                        close(context, '');
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    return _buildSimilarCitiesView(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
    final List<String> recentSearches = weatherProvider.recentSearches;

    // Show matching cities suggestions in real-time as they type if query.length >= 3
    if (query.trim().length >= 3) {
      return _buildSimilarCitiesView(context);
    }

    // Filter recent searches based on current query for short queries
    final List<String> suggestions = query.isEmpty
        ? recentSearches
        : recentSearches
            .where((s) => s.toLowerCase().contains(query.toLowerCase()))
            .toList();

    final Color bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final Color textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final Color subtitleColor = isDark ? Colors.white54 : const Color(0xFF475569);
    final Color dividerColor = isDark ? Colors.white10 : Colors.black12;

    return Container(
      color: bgColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (suggestions.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Searches',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: subtitleColor,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      weatherProvider.clearRecentSearches();
                      query = query; // trigger rebuild
                    },
                    child: Text(
                      'Clear All',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.redAccent.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: suggestions.length,
                separatorBuilder: (_, _) => Divider(
                  height: 1,
                  color: dividerColor,
                  indent: 60,
                ),
                itemBuilder: (context, index) {
                  final String city = suggestions[index];
                  return ListTile(
                    leading: Icon(
                      Icons.history_rounded,
                      color: subtitleColor,
                    ),
                    title: Text(
                      city,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: subtitleColor,
                      ),
                      onPressed: () {
                        weatherProvider.removeRecentSearch(city);
                        query = query; // trigger rebuild
                      },
                    ),
                    onTap: () {
                      query = city;
                      showResults(context);
                    },
                  );
                },
              ),
            ),
          ] else ...[
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      query.isEmpty ? Icons.search_rounded : Icons.location_city_rounded,
                      size: 60,
                      color: subtitleColor.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      query.isEmpty
                          ? 'Search for a city or area'
                          : 'Press search to look up "$query"',
                      style: TextStyle(
                        fontSize: 16,
                        color: subtitleColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      query.isEmpty
                          ? 'Try "London", "Tokyo", or "New York"'
                          : 'Type at least 3 characters to search...',
                      style: TextStyle(
                        fontSize: 13,
                        color: subtitleColor.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
