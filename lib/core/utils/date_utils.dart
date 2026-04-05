import 'package:intl/intl.dart';

String formatDate(DateTime date) {
  return DateFormat('d MMM yyyy').format(date);
}

// Helper method to get month name (Mon, Tue, etc.)
String formatDateForMonth(DateTime date) {
  return DateFormat('MMMM').format(date);
}

// Helper method to get day name (Mon, Tue, etc.)
String getDayName(DateTime date) {
  return DateFormat('EEE').format(date);
}

// Helper method to get day number (01, 02, etc.)
String getDayNumber(DateTime date) {
  return DateFormat('dd').format(date);
}

String formatDateTime(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inDays == 0) {
    if (difference.inHours == 0) {
      if (difference.inMinutes == 0) {
        return 'Just now';
      }
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    }
    return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
  } else if (difference.inDays == 1) {
    return 'Yesterday ${DateFormat('h:mm a').format(dateTime)}';
  } else if (difference.inDays < 7) {
    return DateFormat('EEEE h:mm a').format(dateTime);
  } else {
    return DateFormat('MMMM d, y h:mm a').format(dateTime);
  }
}
