import 'package:fit_ed/helpers/client_page_helpers.dart';
import 'package:fit_ed/widgets/client/client_schedule_picker.dart';
import 'package:flutter/material.dart';

class EditClientFormFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController goalController;
  final TextEditingController notesController;
  final List<String> goalOptions;
  final String? selectedGoal;
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

  const EditClientFormFields({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.goalController,
    required this.notesController,
    required this.goalOptions,
    required this.selectedGoal,
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
    return Column(
      children: [
        TextFormField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Name'),
          validator: (value) => requiredField(value, 'Please enter a name'),
        ),
        clientFieldGap,
        TextFormField(
          controller: emailController,
          decoration: const InputDecoration(labelText: 'Email'),
          keyboardType: TextInputType.emailAddress,
          validator: (value) => requiredField(value, 'Please enter an email'),
        ),
        clientFieldGap,
        TextFormField(
          controller: phoneController,
          decoration: const InputDecoration(labelText: 'Phone'),
          keyboardType: TextInputType.phone,
        ),
        clientFieldGap,
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
        clientFieldGap,
        TextFormField(
          controller: notesController,
          decoration: const InputDecoration(labelText: 'Notes'),
          maxLines: 3,
        ),
      ],
    );
  }
}
