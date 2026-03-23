import 'package:intl/intl.dart';

abstract final class Formatters {
  static final _currencyFormat = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );

  static final _compactCurrencyFormat = NumberFormat.compactCurrency(
    symbol: '\$',
    decimalDigits: 1,
  );

  static String currency(double amount) => _currencyFormat.format(amount);

  static String compactCurrency(double amount) =>
      _compactCurrencyFormat.format(amount);

  static String date(DateTime date) => DateFormat('MMM d, yyyy').format(date);

  static String relativeTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(date);
  }

  static String percentage(double value) => '${value.toStringAsFixed(0)}%';
}
