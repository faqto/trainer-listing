import '../models/client_model.dart';

bool hasSessionToday(Client client) {
  if (client.schedule.trim().isEmpty) return false;

  final weekday = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ][DateTime.now().weekday - 1];

  return client.schedule.toLowerCase().contains(weekday.toLowerCase());
}

bool isToday(DateTime date) {
  final now = DateTime.now();
  return date.year == now.year &&
      date.month == now.month &&
      date.day == now.day;
}

double weightChange(Client client) {
  if (client.progressEntries.length < 2) return 0;

  final sorted = [...client.progressEntries]
    ..sort((a, b) => a.date.compareTo(b.date));
  return sorted.last.weightKg - sorted.first.weightKg;
}
