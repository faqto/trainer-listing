import 'package:flutter/material.dart';

class AssignedCoachBanner extends StatelessWidget {
  final String coachName;

  const AssignedCoachBanner({super.key, required this.coachName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFA7F3D0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_outlined, color: Color(0xFF047857)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Connected with $coachName',
              style: const TextStyle(
                color: Color(0xFF065F46),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
