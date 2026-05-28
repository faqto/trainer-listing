import 'package:fit_ed/pages/home/home_constants.dart';
import 'package:flutter/material.dart';

class DashboardHeader extends StatelessWidget {
  final String trainerName;

  const DashboardHeader({super.key, required this.trainerName});

  String _todayLabel() {
    final now = DateTime.now();
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final day = days[now.weekday - 1];
    final month = months[now.month - 1];
    return '$day, $month ${now.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Coach $trainerName',
                style: const TextStyle(
                  color: inkColor,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _todayLabel(),
                style: const TextStyle(
                  color: mutedColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
