import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDate(DateTime date) {
    return DateFormat('EEE, d MMM yyyy').format(date);
  }

  static String formatTime(DateTime time) {
    return DateFormat('h:mm a').format(time);
  }

  static String formatSessionRange(DateTime startTime, int durationMinutes) {
    final endTime = startTime.add(Duration(minutes: durationMinutes));
    final startStr = DateFormat('h:mm a').format(startTime);
    final endStr = DateFormat('h:mm a').format(endTime);
    return '$startStr — $endStr';
  }

  static String formatShortDate(DateTime date) {
    return DateFormat('d MMM').format(date);
  }
}
