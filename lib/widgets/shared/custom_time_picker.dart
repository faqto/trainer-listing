import 'package:flutter/material.dart';

class CustomTimePicker extends StatefulWidget {
  final TimeOfDay? initialTime;
  final Function(TimeOfDay) onTimeSelected;
  final String label;

  const CustomTimePicker({
    super.key,
    this.initialTime,
    required this.onTimeSelected,
    this.label = 'Select Time',
  });

  @override
  State<CustomTimePicker> createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends State<CustomTimePicker> {
  late TimeOfDay _selectedTime;
  late int _hour;
  late int _minute;
  String _period = 'AM';

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialTime ?? TimeOfDay.now();
    _hour = _selectedTime.hourOfPeriod;
    _minute = _selectedTime.minute;
    _period = _selectedTime.period == DayPeriod.am ? 'AM' : 'PM';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Hour selector
                _buildTimeSelector(
                  value: _hour,
                  onChanged: (value) => setState(() => _hour = value),
                  minValue: 1,
                  maxValue: 12,
                  label: 'Hour',
                ),
                const Text(':', style: TextStyle(fontSize: 24)),
                // Minute selector
                _buildTimeSelector(
                  value: _minute,
                  onChanged: (value) => setState(() => _minute = value),
                  minValue: 0,
                  maxValue: 59,
                  label: 'Min',
                  step: 5,
                ),
                const SizedBox(width: 16),
                // AM/PM selector
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      _buildPeriodButton('AM'),
                      _buildPeriodButton('PM'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSelector({
    required int value,
    required Function(int) onChanged,
    required int minValue,
    required int maxValue,
    required String label,
    int step = 1,
  }) {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove, size: 20),
              onPressed: () {
                final newValue = value - step;
                if (newValue >= minValue) {
                  onChanged(newValue);
                  _updateTime();
                }
              },
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              padding: EdgeInsets.zero,
            ),
            Container(
              width: 50,
              alignment: Alignment.center,
              child: Text(
                value.toString().padLeft(2, '0'),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add, size: 20),
              onPressed: () {
                final newValue = value + step;
                if (newValue <= maxValue) {
                  onChanged(newValue);
                  _updateTime();
                }
              },
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              padding: EdgeInsets.zero,
            ),
          ],
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildPeriodButton(String period) {
    final isSelected = _period == period;
    return GestureDetector(
      onTap: () {
        setState(() {
          _period = period;
          _updateTime();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF8C42) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          period,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  void _updateTime() {
    int hour = _hour;
    if (_period == 'PM' && hour != 12) {
      hour += 12;
    } else if (_period == 'AM' && hour == 12) {
      hour = 0;
    }

    _selectedTime = TimeOfDay(hour: hour, minute: _minute);
    widget.onTimeSelected(_selectedTime);
  }
}

// Alternative: Simple Time Picker Dialog with better UI
class SimpleTimePicker {
  static Future<TimeOfDay?> show({
    required BuildContext context,
    TimeOfDay? initialTime,
  }) async {
    return showDialog<TimeOfDay>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Time'),
          content: SizedBox(
            height: 200,
            child: CustomTimePicker(
              initialTime: initialTime,
              onTimeSelected: (time) {
                Navigator.pop(context, time);
              },
            ),
          ),
        );
      },
    );
  }
}
