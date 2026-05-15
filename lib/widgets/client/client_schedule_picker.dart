import 'package:flutter/material.dart';

import '../../helpers/client_page_helpers.dart';

class ClientSchedulePicker extends StatelessWidget {
  final List<String> selectedDays;
  final TimeOfDay? selectedTime;
  final String? errorText;
  final int durationHours;
  final int durationMinutes;
  final ValueChanged<List<String>> onDaysChanged;
  final ValueChanged<TimeOfDay?> onTimeChanged;
  final ValueChanged<String?> onErrorChanged;
  final ValueChanged<int> onDurationHoursChanged;
  final ValueChanged<int> onDurationMinutesChanged;

  const ClientSchedulePicker({
    super.key,
    required this.selectedDays,
    required this.selectedTime,
    required this.errorText,
    this.durationHours = 0,
    this.durationMinutes = 0,
    required this.onDaysChanged,
    required this.onTimeChanged,
    required this.onErrorChanged,
    required this.onDurationHoursChanged,
    required this.onDurationMinutesChanged,
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
          clientFieldGap,
          const Text(
            'Session Duration',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: durationHours,
                  decoration: InputDecoration(
                    labelText: 'Hours',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: List.generate(5, (i) => i)
                      .map(
                        (h) => DropdownMenuItem(value: h, child: Text('${h}h')),
                      )
                      .toList(),
                  onChanged: (v) => onDurationHoursChanged(v ?? 0),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: durationMinutes,
                  decoration: InputDecoration(
                    labelText: 'Minutes',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: [0, 15, 30, 45]
                      .map(
                        (m) => DropdownMenuItem(value: m, child: Text('${m}m')),
                      )
                      .toList(),
                  onChanged: (v) => onDurationMinutesChanged(v ?? 0),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
