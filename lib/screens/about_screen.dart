import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/theme_provider.dart';
import '../widgets/glassmorphic_card.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  /// Helper to copy link to clipboard and show feedback toast
  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard!'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.accentBlue,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final Color primaryTextColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final Color secondaryTextColor = isDark ? Colors.white70 : const Color(0xFF475569);
    final Color mutedTextColor = isDark
        ? const Color(0x80FFFFFF)
        : const Color(0xFF64748B); // Slate 500
    final List<Color> bgGradient = isDark ? AppTheme.bgNight : AppTheme.bgNightLight;
    final Color dividerColor = isDark ? Colors.white10 : Colors.black12;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'About & Attribution',
          style: TextStyle(fontWeight: FontWeight.bold, color: primaryTextColor),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryTextColor),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: bgGradient,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20.0),
            children: [
              // Header App Info
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    // App Logo
                    Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white : const Color(0xFFF0F9FF),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withValues(alpha: 0.3),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          '💨',
                          style: TextStyle(fontSize: 45),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'ClearBreeze Forecast',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Version 1.0.0',
                      style: TextStyle(color: mutedTextColor, fontSize: 13),
                    ),
                    const SizedBox(height: 25),
                  ],
                ),
              ),

              // Introduction
              GlassmorphicCard(
                child: Text(
                  'ClearBreeze Forecast is a 100% free and open-source weather and air quality monitoring app. It collects real-time meteorological forecasts and air quality parameters to protect your health and plan your day.',
                  style: TextStyle(fontSize: 14, height: 1.4, color: secondaryTextColor),
                ),
              ),
              const SizedBox(height: 20),

              // Developer & Hobby Project Info
              GlassmorphicCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.code_rounded, color: AppTheme.accentBlue, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Developer & Project Info',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: primaryTextColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'ClearBreeze Forecast is a personal hobby project designed and developed by Richard Pius. Built with Flutter, this project is a demonstration of high-quality responsive app engineering, modern state management, and real-time integration with global public APIs.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Divider(color: dividerColor),
                    const SizedBox(height: 8),
                    Text(
                      'Source Code & Repository:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: mutedTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextButton.icon(
                      onPressed: () => _copyToClipboard(
                        context,
                        'https://github.com/richard-pius/ClearBreeze-Forecast',
                        'GitHub Repository Link',
                      ),
                      icon: const Icon(Icons.link_rounded, size: 16, color: Colors.lightBlueAccent),
                      label: const Text(
                        'github.com/richard-pius/ClearBreeze-Forecast',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.lightBlueAccent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // MET Norway Attribution (CC BY 4.0 Requirement)
              _buildSourceCard(
                context,
                title: 'Weather Data Source',
                provider: 'MET Norway',
                description:
                    'Weather forecasts are provided by the Norwegian Meteorological Institute (MET Norway) using their Locationforecast 2.0 API. This data is updated hourly and is globally available.',
                licenseName: 'Creative Commons Attribution 4.0 International (CC BY 4.0)',
                licenseUrl: 'https://creativecommons.org/licenses/by/4.0/',
                termsUrl: 'https://api.met.no/weatherapi/terms/',
                isDark: isDark,
                primaryTextColor: primaryTextColor,
                secondaryTextColor: secondaryTextColor,
                mutedTextColor: mutedTextColor,
              ),
              const SizedBox(height: 20),

              // OpenAQ Attribution (Open Data Requirement)
              _buildSourceCard(
                context,
                title: 'Air Quality Data Source',
                provider: 'OpenAQ Platform',
                description:
                    'Air quality measurements are collected from the OpenAQ platform, an open-source data aggregator that compiles environmental reports from governmental and research institutions globally.',
                licenseName: 'Open AQ Open Data License',
                licenseUrl: 'https://openaq.org',
                termsUrl: 'https://docs.openaq.org',
                isDark: isDark,
                primaryTextColor: primaryTextColor,
                secondaryTextColor: secondaryTextColor,
                mutedTextColor: mutedTextColor,
              ),
              const SizedBox(height: 20),

              // Open Source Software Licenses
              ElevatedButton.icon(
                onPressed: () {
                  showLicensePage(
                    context: context,
                    applicationName: 'ClearBreeze Forecast',
                    applicationVersion: '1.0.0',
                    applicationIcon: const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text('💨', style: TextStyle(fontSize: 40)),
                    ),
                  );
                },
                icon: Icon(Icons.description_rounded, color: primaryTextColor),
                label: Text(
                  'View Software Licenses',
                  style: TextStyle(color: primaryTextColor, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.white.withValues(alpha: 0.5),
                  foregroundColor: primaryTextColor,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.12)
                          : Colors.black.withValues(alpha: 0.08),
                    ),
                  ),
                  elevation: 0,
                ),
              ),
              const SizedBox(height: 20),

              // Disclaimer & Legal Copyright
              GlassmorphicCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.gavel_rounded, color: Colors.amber, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Disclaimer & Copyright',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: primaryTextColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '© 2026 Richard Pius. All rights reserved.\n\n'
                      'This software is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose, and non-infringement. In no event shall the author or copyright holders be liable for any claim, damages, or other liability. Weather and air quality forecasts are informational and fetched from public sources (MET Norway and OpenAQ); accuracy is not guaranteed.',
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.4,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSourceCard(
    BuildContext context, {
    required String title,
    required String provider,
    required String description,
    required String licenseName,
    required String licenseUrl,
    required String termsUrl,
    required bool isDark,
    required Color primaryTextColor,
    required Color secondaryTextColor,
    required Color mutedTextColor,
  }) {
    final Color dividerColor = isDark ? Colors.white10 : Colors.black12;

    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.source_rounded, color: AppTheme.accentBlue, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: primaryTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            provider,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: primaryTextColor.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: secondaryTextColor,
            ),
          ),
          const SizedBox(height: 12),
          Divider(color: dividerColor),
          const SizedBox(height: 8),
          Text(
            'License & Terms:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: mutedTextColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            licenseName,
            style: TextStyle(
              fontSize: 12,
              color: secondaryTextColor,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () => _copyToClipboard(context, licenseUrl, 'License Link'),
                  icon: const Icon(Icons.copy_rounded, size: 14),
                  label: const Text('License Link', style: TextStyle(fontSize: 11)),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.lightBlueAccent,
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                  ),
                ),
              ),
              Expanded(
                child: TextButton.icon(
                  onPressed: () => _copyToClipboard(context, termsUrl, 'API Terms Link'),
                  icon: const Icon(Icons.link_rounded, size: 14),
                  label: const Text('API Terms Link', style: TextStyle(fontSize: 11)),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.lightBlueAccent,
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
