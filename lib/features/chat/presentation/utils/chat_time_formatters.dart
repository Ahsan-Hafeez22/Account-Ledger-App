import 'package:intl/intl.dart';

String formatChatTime(DateTime dt) {
  final local = dt.toLocal();
  return DateFormat('h:mm a').format(local);
}

String formatTimeAgo(DateTime dt, {DateTime? now}) {
  final n = (now ?? DateTime.now()).toLocal();
  final d = dt.toLocal();
  final diff = n.difference(d);

  if (diff.inSeconds < 45) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours} hr ago';

  // Normalize to dates (midnight)
  final today = DateTime(n.year, n.month, n.day);
  final date = DateTime(d.year, d.month, d.day);
  final days = today.difference(date).inDays;

  if (days == 1) return 'Yesterday';
  if (days < 30) return '$days days ago';

  final months = (n.year * 12 + n.month) - (d.year * 12 + d.month);
  if (months < 12) return '${months <= 1 ? 1 : months} month${months == 1 ? '' : 's'} ago';

  final years = n.year - d.year;
  return '$years year${years == 1 ? '' : 's'} ago';
}

