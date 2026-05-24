import 'package:fit_ed/pages/home/home_constants.dart';
import 'package:flutter/material.dart';

class DashboardHeader extends StatelessWidget {
  final String trainerName;

  const DashboardHeader({super.key, required this.trainerName});

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
              const Text(
                'Today at a glance',
                style: TextStyle(
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
