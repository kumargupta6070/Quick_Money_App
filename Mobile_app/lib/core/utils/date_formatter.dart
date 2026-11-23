import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _dateOnlyFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm');
  static final DateFormat _timeOnlyFormat = DateFormat('HH:mm:ss');
  static final DateFormat _prettyDateFormat = DateFormat('dd MMM yyyy');

  static String formatDate(DateTime date) => _dateOnlyFormat.format(date);
  static String formatDateTime(DateTime date) => _dateTimeFormat.format(date);
  static String formatTime(DateTime date) => _timeOnlyFormat.format(date);
  static String formatPretty(DateTime date) => _prettyDateFormat.format(date);

  static String today() => _dateOnlyFormat.format(DateTime.now());
}

