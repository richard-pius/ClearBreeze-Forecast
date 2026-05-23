import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/aqi_card.dart';
import '../widgets/city_search_delegate.dart';
import '../widgets/current_weather_card.dart';
import '../widgets/gradient_background.dart';
import '../widgets/hourly_forecast_list.dart';
import '../widgets/loading_shimmer.dart';
import '../widgets/rain_probability_card.dart';
import '../widgets/weather_detail_row.dart';
import 'about_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch weather data on startup after context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WeatherProvider>(context, listen: false).fetchWeatherData();
    });
  }

  void _openSearch() async {
    final result = await showSearch<String>(
      context: context,
      delegate: CitySearchDelegate(),
    );

    if (result != null && result.trim().isNotEmpty && mounted) {
      Provider.of<WeatherProvider>(context, listen: false)
          .fetchWeatherForCity(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDarkMode;

    // Get current weather symbol code for background gradient
    final String symbolCode = weatherProvider.weatherData?.symbolCode ?? 'clearsky_day';

    // Theme-aware colors
    final Color appBarTextColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final Color actionBgColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFF1E293B).withValues(alpha: 0.06);
    final Color actionBorderColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : const Color(0xFF1E293B).withValues(alpha: 0.15);

    return GradientBackground(
      symbolCode: symbolCode,
      child: Scaffold(
        backgroundColor: Colors.transparent, // transparency reveals the gradient
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Row(
            children: [
              const Text('💨', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(
                'ClearBreeze',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: appBarTextColor,
                ),
              ),
            ],
          ),
          actions: [
            // Search Button
            Container(
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                color: actionBgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: actionBorderColor),
              ),
              child: IconButton(
                icon: Icon(Icons.search_rounded, color: appBarTextColor),
                tooltip: 'Search City',
                onPressed: _openSearch,
              ),
            ),
            // Theme Toggle Button
            Container(
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                color: actionBgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: actionBorderColor),
              ),
              child: IconButton(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return RotationTransition(
                      turns: Tween(begin: 0.75, end: 1.0).animate(animation),
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child: Icon(
                    isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    key: ValueKey(isDark),
                    color: isDark ? Colors.amber : const Color(0xFF1E293B),
                  ),
                ),
                tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                onPressed: () => themeProvider.toggleTheme(),
              ),
            ),
            // C/F Unit Toggle Button
            Container(
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                color: actionBgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: actionBorderColor),
              ),
              child: IconButton(
                icon: Text(
                  '°${weatherProvider.tempUnit}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: appBarTextColor,
                    fontSize: 16,
                  ),
                ),
                tooltip: 'Toggle Temperature Unit',
                onPressed: () => weatherProvider.toggleTempUnit(),
              ),
            ),
            // Info/About Page Button
            Container(
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: actionBgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: actionBorderColor),
              ),
              child: IconButton(
                icon: Icon(Icons.info_outline_rounded, color: appBarTextColor),
                tooltip: 'Attribution & Sources',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AboutScreen()),
                  );
                },
              ),
            ),
          ],
        ),
        body: RefreshIndicator(
          color: Colors.blueAccent,
          backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
          onRefresh: () => weatherProvider.isSearchMode
              ? weatherProvider.fetchWeatherForCity(weatherProvider.searchQuery)
              : weatherProvider.fetchWeatherData(isRefresh: true),
          child: _buildBody(weatherProvider, isDark),
        ),
      ),
    );
  }

  Widget _buildBody(WeatherProvider provider, bool isDark) {
    switch (provider.state) {
      case WeatherState.initial:
      case WeatherState.loading:
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: LoadingShimmer(),
        );

      case WeatherState.error:
        return _buildErrorView(provider, isDark);

      case WeatherState.loaded:
        final weather = provider.weatherData!;
        final aqi = provider.aqiData!;

        final Color primaryTextColor = isDark ? Colors.white : const Color(0xFF1E293B);
        final Color secondaryColor = isDark
            ? Colors.white.withValues(alpha: 0.6)
            : const Color(0xFF475569); // Slate 600

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // "Back to My Location" button when in search mode
              if (provider.isSearchMode)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: GestureDetector(
                    onTap: () => provider.clearSearch(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.white.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.15)
                              : Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.my_location_rounded,
                            size: 16,
                            color: Colors.blueAccent,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Back to My Location',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.blueAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              // Location name
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    provider.isSearchMode
                        ? Icons.location_city_rounded
                        : Icons.location_on_rounded,
                    color: provider.isSearchMode ? Colors.blueAccent : Colors.redAccent,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      provider.locationName,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                        color: primaryTextColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Subtitle
              Text(
                provider.isSearchMode ? 'Searched Location' : 'Current Location Weather',
                style: TextStyle(
                  color: secondaryColor,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 25),

              // Hero Weather card
              CurrentWeatherCard(weatherData: weather),
              const SizedBox(height: 20),

              // Details grid row (Wind, Humidity, Pressure)
              WeatherDetailRow(weatherData: weather),
              const SizedBox(height: 20),

              // Precipitation Probability Card
              RainProbabilityCard(weatherData: weather),
              const SizedBox(height: 20),

              // Air Quality Index Card
              AqiCard(aqiData: aqi),
              const SizedBox(height: 20),

              // Hourly Forecast horizontal list
              HourlyForecastList(hourlyForecasts: weather.hourlyForecasts),
              const SizedBox(height: 30),
            ],
          ),
        );
    }
  }

  Widget _buildErrorView(WeatherProvider provider, bool isDark) {
    final Color primaryTextColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final Color secondaryTextColor = isDark ? Colors.white70 : const Color(0xFF475569);

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.redAccent,
              size: 70,
            ),
            const SizedBox(height: 20),
            Text(
              'Oops! Something Went Wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryTextColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              provider.errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: secondaryTextColor,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 30),
            // Show "Back to My Location" if error was from search
            if (provider.isSearchMode)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: OutlinedButton.icon(
                  onPressed: () => provider.clearSearch(),
                  icon: const Icon(Icons.my_location_rounded),
                  label: const Text('Back to My Location'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blueAccent,
                    side: const BorderSide(color: Colors.blueAccent),
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ElevatedButton.icon(
              onPressed: () => provider.isSearchMode
                  ? provider.fetchWeatherForCity(provider.searchQuery)
                  : provider.fetchWeatherData(),
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              label: const Text(
                'Try Again',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
