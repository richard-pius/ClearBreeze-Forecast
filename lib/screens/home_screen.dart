import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/aqi_card.dart';
import '../widgets/city_search_delegate.dart';
import '../widgets/current_weather_card.dart';
import '../widgets/daily_forecast_list.dart';
import '../widgets/gradient_background.dart';
import '../widgets/hourly_forecast_list.dart';
import '../widgets/loading_shimmer.dart';
import '../widgets/rain_probability_card.dart';
import '../widgets/settings_sheet.dart';
import '../widgets/weather_detail_row.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Kick off the initial fetch after the first frame so we can safely use
    // Provider.of. listen:false — we only need to send the command, we don't
    // rebuild off it here.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherProvider>().fetchWeatherData();
    });
  }

  Future<void> _openSearch() async {
    final result = await showSearch<String>(
      context: context,
      delegate: CitySearchDelegate(),
    );

    if (!mounted) return;
    if (result != null && result.trim().isNotEmpty) {
      context.read<WeatherProvider>().fetchWeatherForCity(result);
    }
  }

  /// Time-of-day greeting for the header.
  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    if (hour < 21) return 'Good evening';
    return 'Good night';
  }

  @override
  Widget build(BuildContext context) {
    // Only the background gradient cares about symbolCode + theme, so use a
    // narrow Selector to avoid rebuilding it on every provider notification.
    final bool isDark = context.select<ThemeProvider, bool>(
      (t) => t.isDarkMode,
    );
    final String symbolCode = context.select<WeatherProvider, String>(
      (w) => w.weatherData?.symbolCode ?? 'clearsky_day',
    );

    final Color appBarTextColor = isDark
        ? Colors.white
        : const Color(0xFF0F172A);
    final Color actionBgColor = isDark
        ? Colors.white.withValues(alpha: 0.10)
        : Colors.white.withValues(alpha: 0.55);
    final Color actionBorderColor = isDark
        ? Colors.white.withValues(alpha: 0.16)
        : Colors.white.withValues(alpha: 0.85);

    return GradientBackground(
      symbolCode: symbolCode,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleSpacing: 20,
          title: Row(
            children: [
              const Text('💨', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Text(
                'ClearBreeze',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: appBarTextColor,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          actions: [
            _AppBarButton(
              icon: Icons.search_rounded,
              tooltip: 'Search city',
              color: appBarTextColor,
              bgColor: actionBgColor,
              borderColor: actionBorderColor,
              onPressed: _openSearch,
            ),
            const SizedBox(width: 6),
            _AppBarButton(
              icon: Icons.tune_rounded,
              tooltip: 'Settings',
              color: appBarTextColor,
              bgColor: actionBgColor,
              borderColor: actionBorderColor,
              onPressed: () => SettingsSheet.show(context),
            ),
            const SizedBox(width: 14),
          ],
        ),
        // Body watches the provider state directly — no need for the outer
        // Provider.of that previously rebuilt every child.
        body: Consumer<WeatherProvider>(
          builder: (context, provider, _) {
            return RefreshIndicator(
              color: const Color(0xFF3B82F6),
              backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
              onRefresh: () => provider.isSearchMode
                  ? provider.fetchWeatherForCity(provider.searchQuery)
                  : provider.fetchWeatherData(isRefresh: true),
              child: _buildBody(provider, isDark),
            );
          },
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

        final Color primaryTextColor = isDark
            ? Colors.white
            : const Color(0xFF0F172A);
        final Color secondaryColor = isDark
            ? Colors.white.withValues(alpha: 0.65)
            : const Color(0xFF475569);
        final Color mutedColor = isDark
            ? Colors.white.withValues(alpha: 0.45)
            : const Color(0xFF64748B);

        // Assemble the section list once; each element gets a staggered
        // fade-in so the loaded view feels alive without being noisy.
        final List<Widget> sections = [
          if (provider.isSearchMode)
            _BackToLocationPill(isDark: isDark, onTap: provider.clearSearch),
          _LocationHeader(
            greeting: _greeting(),
            locationName: provider.locationName,
            isSearchMode: provider.isSearchMode,
            primaryTextColor: primaryTextColor,
            secondaryColor: secondaryColor,
            mutedColor: mutedColor,
          ),
          const SizedBox(height: 22),
          CurrentWeatherCard(weatherData: weather),
          const SizedBox(height: 16),
          WeatherDetailRow(weatherData: weather),
          const SizedBox(height: 16),
          RainProbabilityCard(weatherData: weather),
          const SizedBox(height: 16),
          AqiCard(aqiData: aqi),
          const SizedBox(height: 16),
          HourlyForecastList(hourlyForecasts: weather.hourlyForecasts),
          const SizedBox(height: 16),
          DailyForecastList(dailyForecasts: weather.dailyForecasts),
          const SizedBox(height: 30),
        ];

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int i = 0; i < sections.length; i++)
                _StaggeredFade(
                  // Location — unique key so the pill state animates on
                  // clearSearch, and index-based key for the rest so we don't
                  // re-run animations on every rebuild.
                  key: ValueKey('section-$i-${provider.isSearchMode}'),
                  delay: Duration(milliseconds: 60 * i),
                  child: sections[i],
                ),
            ],
          ),
        );
    }
  }

  Widget _buildErrorView(WeatherProvider provider, bool isDark) {
    final Color primaryTextColor = isDark
        ? Colors.white
        : const Color(0xFF0F172A);
    final Color secondaryTextColor = isDark
        ? Colors.white70
        : const Color(0xFF475569);

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
              'Oops! Something went wrong',
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
              style: TextStyle(color: secondaryTextColor, height: 1.4),
            ),
            const SizedBox(height: 30),
            if (provider.isSearchMode)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: OutlinedButton.icon(
                  onPressed: provider.clearSearch,
                  icon: const Icon(Icons.my_location_rounded),
                  label: const Text('Back to My Location'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF3B82F6),
                    side: const BorderSide(color: Color(0xFF3B82F6)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 12,
                    ),
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
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 12,
                ),
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

/// A pill-shaped icon button used across the AppBar actions.
class _AppBarButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color color;
  final Color bgColor;
  final Color borderColor;

  const _AppBarButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    required this.color,
    required this.bgColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
        ),
      ),
    );
  }
}

/// The greeting + location header shown above the hero card.
class _LocationHeader extends StatelessWidget {
  final String greeting;
  final String locationName;
  final bool isSearchMode;
  final Color primaryTextColor;
  final Color secondaryColor;
  final Color mutedColor;

  const _LocationHeader({
    required this.greeting,
    required this.locationName,
    required this.isSearchMode,
    required this.primaryTextColor,
    required this.secondaryColor,
    required this.mutedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          greeting,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.4,
            color: mutedColor,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSearchMode
                  ? Icons.location_city_rounded
                  : Icons.location_on_rounded,
              color: isSearchMode
                  ? const Color(0xFF60A5FA)
                  : const Color(0xFFF87171),
              size: 20,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                locationName,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                  color: primaryTextColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          isSearchMode ? 'Searched location' : 'Your current location',
          style: TextStyle(color: secondaryColor, fontSize: 12),
        ),
      ],
    );
  }
}

/// Pill button shown at the top when the user is viewing a searched city.
class _BackToLocationPill extends StatelessWidget {
  final bool isDark;
  final VoidCallback onTap;

  const _BackToLocationPill({required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.15)
                      : Colors.white.withValues(alpha: 0.7),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.my_location_rounded,
                    size: 16,
                    color: Color(0xFF60A5FA),
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Back to my location',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF60A5FA),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Fades and slides its child in with a small [delay]. One-shot animation
/// tied to the widget's lifecycle — no controller retention overhead once
/// it completes.
class _StaggeredFade extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const _StaggeredFade({super.key, required this.child, required this.delay});

  @override
  State<_StaggeredFade> createState() => _StaggeredFadeState();
}

class _StaggeredFadeState extends State<_StaggeredFade>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _offset = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _offset, child: widget.child),
    );
  }
}
