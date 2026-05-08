import 'package:flutter/material.dart';

const clientPageBackgroundColor = Color(0xFFEFF5FB);
const clientPageAppBarColor = Color(0xFF13294B);
const clientFieldGap = SizedBox(height: 12);
const clientSectionGap = SizedBox(height: 16);

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

class ClientSectionCard extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  const ClientSectionCard({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140F172A),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
          BoxShadow(
            color: Color(0x080F172A),
            blurRadius: 44,
            offset: Offset(0, 24),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class ClientSectionTitle extends StatelessWidget {
  final String text;

  const ClientSectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}
