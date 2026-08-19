import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/weather_provider.dart';
import '../screens/about_screen.dart';

/// A rounded modal bottom sheet that groups every app-level toggle (theme,
/// temperature unit) plus the entry point into About / Attribution. It keeps
/// the AppBar clean by pulling secondary controls out into a single button.
class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const SettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final weatherProvider = context.watch<WeatherProvider>();
    final bool isDark = themeProvider.isDarkMode;

    final Color surface =
        isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final Color primary = isDark ? Colors.white : const Color(0xFF0F172A);
    final Color secondary =
        isDark ? Colors.white70 : const Color(0xFF475569);
    final Color muted = isDark ? Colors.white38 : const Color(0xFF94A3B8);
    final Color divider = isDark ? Colors.white10 : Colors.black12;

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle.
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: muted,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Settings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Personalize your ClearBreeze experience.',
                style: TextStyle(fontSize: 13, color: secondary),
              ),
              const SizedBox(height: 20),

              // Theme segmented toggle.
              _SectionLabel(text: 'Appearance', color: muted),
              const SizedBox(height: 8),
              _SegmentedToggle(
                selectedIndex: isDark ? 1 : 0,
                onChanged: (i) {
                  // Only toggle when it changes state.
                  if ((i == 1) != themeProvider.isDarkMode) {
                    themeProvider.toggleTheme();
                  }
                },
                options: const [
                  _SegmentOption(icon: Icons.light_mode_rounded, label: 'Light'),
                  _SegmentOption(icon: Icons.dark_mode_rounded, label: 'Dark'),
                ],
                isDark: isDark,
              ),
              const SizedBox(height: 20),

              _SectionLabel(text: 'Temperature Unit', color: muted),
              const SizedBox(height: 8),
              _SegmentedToggle(
                selectedIndex: weatherProvider.isCelsius ? 0 : 1,
                onChanged: (i) {
                  final wantsCelsius = i == 0;
                  if (wantsCelsius != weatherProvider.isCelsius) {
                    weatherProvider.toggleTempUnit();
                  }
                },
                options: const [
                  _SegmentOption(label: 'Celsius', trailing: '°C'),
                  _SegmentOption(label: 'Fahrenheit', trailing: '°F'),
                ],
                isDark: isDark,
              ),
              const SizedBox(height: 20),

              Divider(color: divider, height: 1),
              const SizedBox(height: 12),

              // About / Attribution link.
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white : Colors.black)
                        .withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.info_outline_rounded, color: primary),
                ),
                title: Text(
                  'About & Attribution',
                  style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Data sources, licenses, and credits',
                  style: TextStyle(color: secondary, fontSize: 12),
                ),
                trailing:
                    Icon(Icons.chevron_right_rounded, color: secondary),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AboutScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final Color color;
  const _SectionLabel({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: color,
      ),
    );
  }
}

class _SegmentOption {
  final IconData? icon;
  final String label;
  final String? trailing;
  const _SegmentOption({this.icon, required this.label, this.trailing});
}

class _SegmentedToggle extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final List<_SegmentOption> options;
  final bool isDark;

  const _SegmentedToggle({
    required this.selectedIndex,
    required this.onChanged,
    required this.options,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final Color trackBg = (isDark ? Colors.white : Colors.black)
        .withValues(alpha: isDark ? 0.06 : 0.04);
    final Color selectedBg =
        isDark ? const Color(0xFF3B82F6) : const Color(0xFF0F172A);
    final Color selectedText = Colors.white;
    final Color unselectedText =
        isDark ? Colors.white70 : const Color(0xFF475569);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: trackBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: List.generate(options.length, (i) {
          final opt = options[i];
          final bool sel = i == selectedIndex;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: sel ? selectedBg : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (opt.icon != null) ...[
                      Icon(
                        opt.icon,
                        size: 16,
                        color: sel ? selectedText : unselectedText,
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      opt.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: sel ? selectedText : unselectedText,
                      ),
                    ),
                    if (opt.trailing != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        opt.trailing!,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: sel ? selectedText : unselectedText,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
