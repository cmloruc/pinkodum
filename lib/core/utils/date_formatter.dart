import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String format(DateTime date) => DateFormat('dd.MM.yyyy').format(date);

  static String formatLong(DateTime date) =>
      DateFormat('d MMMM yyyy', 'tr_TR').format(date);

  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Bugün';
    if (diff.inDays == 1) return 'Dün';
    if (diff.inDays < 7) return '${diff.inDays} gün önce';
    return format(date);
  }
}
