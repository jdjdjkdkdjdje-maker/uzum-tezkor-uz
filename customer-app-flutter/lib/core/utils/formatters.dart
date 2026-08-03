import 'package:intl/intl.dart';

class Formatters {
  static final _priceFormat = NumberFormat.decimalPattern('uz');

  static String price(num amount) => "${_priceFormat.format(amount)} so'm";

  static String priceCompact(num amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)} mln so\'m';
    }
    return price(amount);
  }

  static String timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'hozirgina';
    if (diff.inMinutes < 60) return '${diff.inMinutes} daqiqa oldin';
    if (diff.inHours < 24) return '${diff.inHours} soat oldin';
    return '${diff.inDays} kun oldin';
  }

  static String dateTime(DateTime dateTime) {
    return DateFormat('dd.MM.yyyy, HH:mm').format(dateTime);
  }
}
