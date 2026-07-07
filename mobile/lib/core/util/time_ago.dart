String timeAgoBn(String iso) {
  final dt = DateTime.tryParse(iso);
  if (dt == null) return '';
  final diff = DateTime.now().difference(dt.toLocal());
  final mins = diff.inMinutes;
  if (mins < 1) return 'এইমাত্র';
  if (mins < 60) return '$mins মিনিট আগে';
  final hours = diff.inHours;
  if (hours < 24) return '$hours ঘণ্টা আগে';
  return '${diff.inDays} দিন আগে';
}
