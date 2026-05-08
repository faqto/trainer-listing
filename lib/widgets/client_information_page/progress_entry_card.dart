import 'package:flutter/material.dart';

import '../../models/client_model.dart';

class ProgressEntryCard extends StatelessWidget {
  final ProgressEntry entry;

  const ProgressEntryCard({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final bmi = entry.bmi == null ? '--' : entry.bmi!.toStringAsFixed(1);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            entry.dateLabel,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Weight ${entry.weightKg.toStringAsFixed(1)} kg | BMI $bmi | Body fat ${entry.bodyFatPercent.toStringAsFixed(1)}%',
          ),
          if (entry.note.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(entry.note, style: const TextStyle(color: Colors.black54)),
          ],
        ],
      ),
    );
  }
}
