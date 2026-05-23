import 'package:intl/intl.dart';

class DateFormatter {
  /// Formats a DateTime to show hour and AM/PM: e.g., "12:00 PM"
  static String formatHour(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime.toLocal());
  }

  /// Formats a DateTime to show short hour: e.g., "12 PM"
  static String formatShortHour(DateTime dateTime) {
    return DateFormat('ha').format(dateTime.toLocal());
  }

  /// Formats a DateTime to show full weekday and date: e.g., "Saturday, May 23"
  static String formatFullDate(DateTime dateTime) {
    return DateFormat('EEEE, MMMM d').format(dateTime.toLocal());
  }

  /// Returns "Today", "Tomorrow", or the day name (e.g., "Monday")
  static String formatDayName(DateTime dateTime) {
    final DateTime now = DateTime.now();
    final DateTime localDateTime = dateTime.toLocal();

    if (localDateTime.year == now.year &&
        localDateTime.month == now.month &&
        localDateTime.day == now.day) {
      return 'Today';
    }

    final DateTime tomorrow = now.add(const Duration(days: 1));
    if (localDateTime.year == tomorrow.year &&
        localDateTime.month == tomorrow.month &&
        localDateTime.day == tomorrow.day) {
      return 'Tomorrow';
    }

    return DateFormat('EEEE').format(localDateTime);
  }

  /// Formats a DateTime to show last update timestamp: e.g., "Last updated: 12:45 PM"
  static String formatLastUpdated(DateTime dateTime) {
    return 'Last updated: ${DateFormat('h:mm a').format(dateTime.toLocal())}';
  }
}
