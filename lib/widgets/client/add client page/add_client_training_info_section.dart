import 'package:flutter/material.dart';

import '../client_schedule_picker.dart';
import '../client_section_card.dart';
import '../client_section_title.dart';
import '../../../helpers/client_page_helpers.dart';

class AddClientTrainingInfoSection extends StatelessWidget {
  final List<String> goalOptions;
  final String? selectedGoal;
  final TextEditingController goalController;
  final List<String> selectedDays;
  final TimeOfDay? scheduleTime;
  final String? scheduleError;
  final int durationHours;
  final int durationMinutes;
  final ValueChanged<String?> onGoalChanged;
  final ValueChanged<List<String>> onDaysChanged;
  final ValueChanged<TimeOfDay?> onTimeChanged;
  final ValueChanged<String?> onErrorChanged;
  final ValueChanged<int> onDurationHoursChanged;
  final ValueChanged<int> onDurationMinutesChanged;

  const AddClientTrainingInfoSection({
    super.key,
    required this.goalOptions,
    required this.selectedGoal,
    required this.goalController,
    required this.selectedDays,
    required this.scheduleTime,
    required this.scheduleError,
    this.durationHours = 0,
    this.durationMinutes = 0,
    required this.onGoalChanged,
    required this.onDaysChanged,
    required this.onTimeChanged,
    required this.onErrorChanged,
    required this.onDurationHoursChanged,
    required this.onDurationMinutesChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ClientSectionCard(
      padding: const EdgeInsets.all(18),
      children: [
        const ClientSectionTitle('Training Info'),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: selectedGoal,
          items: goalOptions.map((goal) {
            return DropdownMenuItem(value: goal, child: Text(goal));
          }).toList(),
          onChanged: onGoalChanged,
          decoration: const InputDecoration(labelText: 'Training Goal'),
          validator: (value) => value == null ? 'Select a goal' : null,
        ),
        clientFieldGap,
        if (selectedGoal == otherGoalOption)
          Column(
            children: [
              TextFormField(
                controller: goalController,
                decoration: const InputDecoration(
                  labelText: 'Specify your goal',
                ),
                validator: (value) =>
                    requiredField(value, 'Please specify your goal'),
              ),
              clientFieldGap,
            ],
          ),
        ClientSchedulePicker(
          selectedDays: selectedDays,
          selectedTime: scheduleTime,
          errorText: scheduleError,
          durationHours: durationHours,
          durationMinutes: durationMinutes,
          onDaysChanged: onDaysChanged,
          onTimeChanged: onTimeChanged,
          onErrorChanged: onErrorChanged,
          onDurationHoursChanged: onDurationHoursChanged,
          onDurationMinutesChanged: onDurationMinutesChanged,
        ),
      ],
    );
  }
}
