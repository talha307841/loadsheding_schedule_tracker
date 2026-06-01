import 'package:intl/intl.dart';

class DateTimeUtils {
  static final DateFormat weekdayFormat = DateFormat('EEEE');
  static final DateFormat timeFormat = DateFormat('hh:mm a');
  static final DateFormat dateFormat = DateFormat('dd MMM yyyy');

  static String formatWeekday(DateTime dateTime) => weekdayFormat.format(dateTime);
  static String formatTime(DateTime dateTime) => timeFormat.format(dateTime);
  static String formatDate(DateTime dateTime) => dateFormat.format(dateTime);

  static DateTime parseHHmm(String value, {DateTime? baseDate}) {
    final parts = value.split(':');
    final date = baseDate ?? DateTime.now();
    return DateTime(date.year, date.month, date.day, int.parse(parts[0]), int.parse(parts[1]));
  }

  static String formatDuration(Duration duration) {
    if (duration.isNegative) {
      return '00:00:00';
    }
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
