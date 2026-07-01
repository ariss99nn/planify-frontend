// lib/core/date_format.dart
String formatDate(DateTime? date) {
  if (date == null) return '—';
  final d = date.day.toString().padLeft(2, '0');
  final m = date.month.toString().padLeft(2, '0');
  final y = date.year.toString();
  return '$d/$m/$y';
}