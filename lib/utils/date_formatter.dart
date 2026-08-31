import 'package:intl/intl.dart';

class DateFormatter {
  /// True when both instants fall on the same local calendar day.
  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Short hour label for the hourly strip: e.g. "12 PM".
  static String formatShortHour(DateTime dateTime) {
    return DateFormat('ha').format(dateTime.toLocal());
  }

  /// Full weekday and date for the hero card: e.g. "Saturday, May 23".
  static String formatFullDate(DateTime dateTime) {
    return DateFormat('EEEE, MMMM d').format(dateTime.toLocal());
  }

  /// Day label for the 7-day forecast: "Today", "Tomorrow", or an abbreviated
  /// weekday such as "Wed".
  ///
  /// Abbreviated deliberately — full names like "Wednesday" overflow the
  /// fixed-width day column on narrow (320dp) screens.
  static String formatShortDayName(DateTime dateTime) {
    final DateTime now = DateTime.now();
    final DateTime local = dateTime.toLocal();

    if (_isSameDay(local, now)) return 'Today';
    if (_isSameDay(local, now.add(const Duration(days: 1)))) return 'Tomorrow';

    return DateFormat('EEE').format(local);
  }
}
