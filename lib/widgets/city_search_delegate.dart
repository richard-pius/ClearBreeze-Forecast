import 'dart:async';

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
    final _Palette p = _Palette.of(isDark);

    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: p.background,
        elevation: 0,
        iconTheme: IconThemeData(color: p.text),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: p.subtitle, fontSize: 16),
        border: InputBorder.none,
      ),
      textTheme: theme.textTheme.copyWith(
        titleLarge: TextStyle(color: p.text, fontSize: 16),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    final _Palette p = _Palette.of(
      Theme.of(context).brightness == Brightness.dark,
    );

    return [
      if (query.isNotEmpty)
        IconButton(
          icon: Icon(Icons.clear_rounded, color: p.text),
          tooltip: 'Clear',
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
      IconButton(
        icon: Icon(Icons.search_rounded, color: p.text),
        tooltip: 'Search',
        onPressed: () {
          if (query.trim().isNotEmpty) showResults(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    final _Palette p = _Palette.of(
      Theme.of(context).brightness == Brightness.dark,
    );

    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: const AlwaysStoppedAnimation(1.0),
        color: p.text,
      ),
      tooltip: 'Back',
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.trim().isEmpty) return const SizedBox.shrink();
    return _CityResultsView(
      query: query.trim(),
      onPicked: () => close(context, ''),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Live lookup once the query is specific enough to be worth geocoding.
    if (query.trim().length >= 3) {
      return _CityResultsView(
        query: query.trim(),
        onPicked: () => close(context, ''),
      );
    }
    return _RecentSearchesView(
      query: query,
      onSelect: (city) {
        query = city;
        showResults(context);
      },
    );
  }
}

/// Geocoding results for a query.
///
/// This is a StatefulWidget on purpose. [SearchDelegate.buildSuggestions] is
/// invoked on every keystroke, so building the future inline in `build()`
/// would fire a fresh forward-geocode plus up to five reverse-geocodes per
/// character typed — enough to jank the UI and trip the platform geocoder
/// rate limit. Here the request is debounced, and the resulting future is
/// cached until the query actually changes.
class _CityResultsView extends StatefulWidget {
  final String query;
  final VoidCallback onPicked;

  const _CityResultsView({required this.query, required this.onPicked});

  @override
  State<_CityResultsView> createState() => _CityResultsViewState();
}

class _CityResultsViewState extends State<_CityResultsView> {
  static const Duration _debounce = Duration(milliseconds: 350);

  Timer? _timer;
  Future<List<Map<String, dynamic>>>? _future;
  String? _requestedQuery;

  @override
  void initState() {
    super.initState();
    _schedule(widget.query);
  }

  @override
  void didUpdateWidget(covariant _CityResultsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query) _schedule(widget.query);
  }

  /// Debounce, then kick off exactly one lookup per settled query.
  void _schedule(String query) {
    if (query == _requestedQuery) return; // Already resolved or in flight.

    _timer?.cancel();
    _timer = Timer(_debounce, () {
      if (!mounted) return;
      setState(() {
        _requestedQuery = query;
        _future = LocationService.getSimilarCities(query);
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _Palette p = _Palette.of(
      Theme.of(context).brightness == Brightness.dark,
    );

    return Container(
      color: p.background,
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          // A null future means we are still inside the debounce window.
          if (_future == null ||
              snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF3B82F6)),
            );
          }

          if (snapshot.hasError) {
            return _SearchMessage(
              icon: Icons.error_outline_rounded,
              iconColor: Colors.redAccent,
              title: 'Error searching for "${widget.query}"',
              subtitle: snapshot.error.toString().replaceAll('Exception: ', ''),
              palette: p,
            );
          }

          final List<Map<String, dynamic>> cities = snapshot.data ?? const [];

          if (cities.isEmpty) {
            return _SearchMessage(
              icon: Icons.location_off_rounded,
              iconColor: p.subtitle.withValues(alpha: 0.5),
              title: 'No matching cities found for "${widget.query}"',
              subtitle: 'Try checking the spelling or typing another name.',
              palette: p,
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
                    color: p.subtitle,
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: cities.length,
                  separatorBuilder: (_, _) =>
                      Divider(height: 1, color: p.divider, indent: 60),
                  itemBuilder: (context, index) {
                    final Map<String, dynamic> city = cities[index];
                    final double lat = city['latitude'] as double;
                    final double lon = city['longitude'] as double;
                    final String name = city['name'] as String;

                    return ListTile(
                      leading: const Icon(
                        Icons.location_city_rounded,
                        color: Color(0xFF3B82F6),
                      ),
                      title: Text(
                        name,
                        style: TextStyle(
                          color: p.text,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        'Lat: ${lat.toStringAsFixed(3)}°, '
                        'Lon: ${lon.toStringAsFixed(3)}°',
                        style: TextStyle(
                          color: p.subtitle.withValues(alpha: 0.8),
                          fontSize: 11,
                        ),
                      ),
                      onTap: () {
                        context
                            .read<WeatherProvider>()
                            .fetchWeatherForCoordinates(lat, lon, name);
                        widget.onPicked();
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
}

/// Recent-search list shown while the query is too short to geocode.
///
/// Watches the provider so removals repaint on their own — the previous
/// implementation relied on a `query = query` self-assignment to nudge
/// SearchDelegate into rebuilding.
class _RecentSearchesView extends StatelessWidget {
  final String query;
  final ValueChanged<String> onSelect;

  const _RecentSearchesView({required this.query, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final _Palette p = _Palette.of(
      Theme.of(context).brightness == Brightness.dark,
    );
    final provider = context.watch<WeatherProvider>();

    final List<String> suggestions = query.isEmpty
        ? provider.recentSearches
        : provider.recentSearches
              .where((s) => s.toLowerCase().contains(query.toLowerCase()))
              .toList(growable: false);

    if (suggestions.isEmpty) {
      return Container(
        color: p.background,
        child: _SearchMessage(
          icon: query.isEmpty
              ? Icons.search_rounded
              : Icons.location_city_rounded,
          iconColor: p.subtitle.withValues(alpha: 0.5),
          title: query.isEmpty
              ? 'Search for a city or area'
              : 'Press search to look up "$query"',
          subtitle: query.isEmpty
              ? 'Try "London", "Tokyo", or "New York"'
              : 'Type at least 3 characters to search...',
          palette: p,
          iconSize: 60,
        ),
      );
    }

    return Container(
      color: p.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    color: p.subtitle,
                  ),
                ),
                TextButton(
                  onPressed: provider.clearRecentSearches,
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
              separatorBuilder: (_, _) =>
                  Divider(height: 1, color: p.divider, indent: 60),
              itemBuilder: (context, index) {
                final String city = suggestions[index];
                return ListTile(
                  leading: Icon(Icons.history_rounded, color: p.subtitle),
                  title: Text(
                    city,
                    style: TextStyle(
                      color: p.text,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: p.subtitle,
                    ),
                    tooltip: 'Remove',
                    onPressed: () => provider.removeRecentSearch(city),
                  ),
                  onTap: () => onSelect(city),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Centered icon + title + subtitle used for every empty / error state.
class _SearchMessage extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final _Palette palette;
  final double iconSize;

  const _SearchMessage({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.palette,
    this.iconSize = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: iconSize),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: palette.text,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: palette.subtitle, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

/// Theme-aware colors for the search surface.
class _Palette {
  final Color background;
  final Color text;
  final Color subtitle;
  final Color divider;

  const _Palette({
    required this.background,
    required this.text,
    required this.subtitle,
    required this.divider,
  });

  factory _Palette.of(bool isDark) {
    return _Palette(
      background: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      text: isDark ? Colors.white : const Color(0xFF0F172A),
      subtitle: isDark ? Colors.white54 : const Color(0xFF475569),
      divider: isDark ? Colors.white10 : Colors.black12,
    );
  }
}
