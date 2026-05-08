import 'package:flutter/material.dart';

const clientPageBackgroundColor = Color(0xFFEFF5FB);
const clientPageAppBarColor = Color(0xFF13294B);
const clientFieldGap = SizedBox(height: 12);
const clientSectionGap = SizedBox(height: 16);
const otherGoalOption = 'Others - please specify';
const scheduleDayOptions = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

String? requiredField(String? value, String message) {
  return value == null || value.trim().isEmpty ? message : null;
}

List<String> parseScheduleDays(String schedule) {
  return schedule
      .split(' at ')
      .first
      .split(' / ')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();
}

String formatScheduleDays(
  List<String> days,
  TimeOfDay? time,
  BuildContext context,
) {
  if (days.isEmpty) return '';
  final base = days.join(' / ');
  return time == null ? base : '$base at ${time.format(context)}';
}

double parseMetric(String value) {
  return double.tryParse(value.replaceAll(',', '.')) ?? 0;
}

String formatScheduleDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$month/$day/${date.year}';
}

String formatSchedule(DateTime? date, TimeOfDay? time, BuildContext context) {
  if (date == null || time == null) return '';
  return '${formatScheduleDate(date)} at ${time.format(context)}';
}

DateTime? parseScheduleDate(String schedule) {
  final dateText = schedule.split(' at ').first.trim();
  final parts = dateText.split('/');
  if (parts.length != 3) return null;

  final month = int.tryParse(parts[0]);
  final day = int.tryParse(parts[1]);
  final year = int.tryParse(parts[2]);
  if (month == null || day == null || year == null) return null;

  return DateTime(year, month, day);
}

TimeOfDay? parseScheduleTime(String schedule) {
  final parts = schedule.split(' at ');
  if (parts.length != 2) return null;

  final match = RegExp(
    r'^(\d{1,2}):(\d{2})\s*([AP]M)?$',
    caseSensitive: false,
  ).firstMatch(parts[1].trim());
  if (match == null) return null;

  var hour = int.tryParse(match.group(1)!);
  final minute = int.tryParse(match.group(2)!);
  final marker = match.group(3)?.toUpperCase();
  if (hour == null || minute == null) return null;

  if (marker == 'PM' && hour < 12) hour += 12;
  if (marker == 'AM' && hour == 12) hour = 0;
  if (hour > 23 || minute > 59) return null;

  return TimeOfDay(hour: hour, minute: minute);
}
