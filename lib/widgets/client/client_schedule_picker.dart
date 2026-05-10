import 'package:flutter/material.dart';

import '../../helpers/client_page_helpers.dart';

class ClientSchedulePicker extends StatelessWidget {
  final List<String> selectedDays;
  final TimeOfDay? selectedTime;
  final String? errorText;
  final ValueChanged<List<String>> onDaysChanged;
  final ValueChanged<TimeOfDay?> onTimeChanged;
  final ValueChanged<String?> onErrorChanged;

  const ClientSchedulePicker({
    super.key,
    required this.selectedDays,
    required this.selectedTime,
    required this.errorText,
    required this.onDaysChanged,
    required this.onTimeChanged,
    required this.onErrorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Schedule Days',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: scheduleDayOptions.map((day) {
            return FilterChip(
              label: Text(day),
              selected: selectedDays.contains(day),
              onSelected: (selected) {
                final updatedDays = [...selectedDays];
                if (selected) {
                  updatedDays.add(day);
                } else {
                  updatedDays.remove(day);
                }

                onDaysChanged(updatedDays);
                if (updatedDays.isEmpty) {
                  onTimeChanged(null);
                  onErrorChanged(null);
                }
              },
            );
          }).toList(),
        ),
        if (selectedDays.isNotEmpty) ...[
          clientFieldGap,
          GestureDetector(
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: selectedTime ?? TimeOfDay.now(),
              );
              if (picked != null) {
                onTimeChanged(picked);
                onErrorChanged(null);
              }
            },
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Schedule Time',
                suffixIcon: const Icon(Icons.access_time),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                errorText: errorText,
              ),
              child: Text(selectedTime?.format(context) ?? 'Select time'),
            ),
          ),
        ],
      ],
    );
  }
}
