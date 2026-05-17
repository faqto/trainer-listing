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
  BuildContext context, {
  int durationHours = 0,
  int durationMinutes = 0,
}) {
  if (days.isEmpty) return '';
  final base = days.join(' / ');
  if (time == null) return base;
  final timeStr = '$base at ${time.format(context)}';
  final totalMinutes = durationHours * 60 + durationMinutes;
  if (totalMinutes <= 0) return timeStr;
  final durStr = durationHours > 0 && durationMinutes > 0
      ? '${durationHours}h ${durationMinutes}m'
      : durationHours > 0
      ? '${durationHours}h'
      : '${durationMinutes}m';
  return '$timeStr for $durStr';
}

/// Parses duration from schedule string like "Mon / Wed at 6:00 PM for 1h 30m"
/// Returns duration in minutes, or 0 if not found.
int parseScheduleDurationMinutes(String schedule) {
  final forMatch = RegExp(r'for (.+)$').firstMatch(schedule);
  if (forMatch == null) return 0;
  final durStr = forMatch.group(1)!.trim();
  final hMatch = RegExp(r'(\d+)h').firstMatch(durStr);
  final mMatch = RegExp(r'(\d+)m').firstMatch(durStr);
  final hours = hMatch != null ? int.tryParse(hMatch.group(1)!) ?? 0 : 0;
  final minutes = mMatch != null ? int.tryParse(mMatch.group(1)!) ?? 0 : 0;
  return hours * 60 + minutes;
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
  final timeText = parts[1].split(' for ').first.trim();

  final match = RegExp(
    r'^(\d{1,2}):(\d{2})\s*([AP]M)?$',
    caseSensitive: false,
  ).firstMatch(timeText);
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
