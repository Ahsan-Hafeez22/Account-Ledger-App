import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  String get formatted => DateFormat('MMM d, yyyy').format(this);

  String get timeFormatted => DateFormat('h:mm a').format(this);

  String get dayMonth => DateFormat('MMM d').format(this);

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  String get relativeLabel {
    if (isToday) return 'Today';
    if (isYesterday) return 'Yesterday';
    return formatted;
  }

  DateTime get startOfDay => DateTime(year, month, day);

  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59);
}


/*
DateTime now = DateTime.now();

print(now.formatted); 
// Mar 22, 2026

print(now.timeFormatted); 
// 3:45 PM

print(now.dayMonth); 
// Mar 22

if (messageDate.isToday) {
  print("Show 'Today'");
}

print(messageDate.relativeLabel);
Today
Yesterday
Mar 20, 2026
*/