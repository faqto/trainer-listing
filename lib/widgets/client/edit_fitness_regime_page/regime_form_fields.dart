import 'package:flutter/material.dart';
import '../../../widgets/client/client_schedule_picker.dart';
import '../../../helpers/client_page_helpers.dart';

class RegimeFormFields extends StatelessWidget {
  final List<String> selectedDays;
  final TimeOfDay? scheduleTime;
  final String? scheduleError;
  final int durationHours;
  final int durationMinutes;
  final TextEditingController regimeController;
  final TextEditingController cardioController;
  final bool isSaving;
  final Function({
    List<String>? days,
    TimeOfDay? time,
    String? error,
    int? hours,
    int? minutes,
  })
  onScheduleChanged;
  final VoidCallback onSave;

  const RegimeFormFields({
    super.key,
    required this.selectedDays,
    required this.scheduleTime,
    required this.scheduleError,
    required this.durationHours,
    required this.durationMinutes,
    required this.regimeController,
    required this.cardioController,
    required this.isSaving,
    required this.onScheduleChanged,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ClientSchedulePicker(
          selectedDays: selectedDays,
          selectedTime: scheduleTime,
          errorText: scheduleError,
          durationHours: durationHours,
          durationMinutes: durationMinutes,
          onDaysChanged: (days) => onScheduleChanged(days: days),
          onTimeChanged: (time) => onScheduleChanged(time: time),
          onErrorChanged: (error) => onScheduleChanged(error: error),
          onDurationHoursChanged: (hours) => onScheduleChanged(hours: hours),
          onDurationMinutesChanged: (minutes) =>
              onScheduleChanged(minutes: minutes),
        ),
        clientFieldGap,
        _buildTextField(
          controller: regimeController,
          label: 'Strength / workout regime',
          minLines: 4,
          maxLines: 6,
          validator: (value) => requiredField(value, 'Enter a regime'),
        ),
        clientFieldGap,
        _buildTextField(
          controller: cardioController,
          label: 'Cardio / conditioning plan',
          minLines: 3,
          maxLines: 5,
        ),
        const SizedBox(height: 24),
        _buildSaveButton(),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required int minLines,
    required int maxLines,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label, alignLabelWithHint: true),
      minLines: minLines,
      maxLines: maxLines,
      validator: validator,
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: isSaving ? null : onSave,
      child: isSaving
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text('Save Regime'),
    );
  }
}
