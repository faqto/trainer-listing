import 'package:flutter/material.dart';
import '../client/client_schedule_picker.dart';

class ScheduleFormSection extends StatelessWidget {
  final List<String> selectedDays;
  final TimeOfDay? scheduleTime;
  final String? errorText;
  final int durationHours;
  final int durationMinutes;
  final Function(List<String>) onDaysChanged;
  final Function(TimeOfDay?) onTimeChanged;
  final Function(String?) onErrorChanged;
  final Function(int) onHoursChanged;
  final Function(int) onMinutesChanged;

  const ScheduleFormSection({
    super.key,
    required this.selectedDays,
    required this.scheduleTime,
    required this.errorText,
    required this.durationHours,
    required this.durationMinutes,
    required this.onDaysChanged,
    required this.onTimeChanged,
    required this.onErrorChanged,
    required this.onHoursChanged,
    required this.onMinutesChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ClientSchedulePicker(
      selectedDays: selectedDays,
      selectedTime: scheduleTime,
      errorText: errorText,
      durationHours: durationHours,
      durationMinutes: durationMinutes,
      onDaysChanged: onDaysChanged,
      onTimeChanged: onTimeChanged,
      onErrorChanged: onErrorChanged,
      onDurationHoursChanged: onHoursChanged,
      onDurationMinutesChanged: onMinutesChanged,
    );
  }
}
