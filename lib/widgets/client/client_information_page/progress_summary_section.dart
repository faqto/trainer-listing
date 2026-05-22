import 'package:fit_ed/widgets/client/client_information_page/metric_row.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../../../models/client_model.dart';
import '../../../widgets/client/client_section_card.dart';
import '../../../widgets/client/client_section_title.dart';

class ProgressSummarySection extends StatelessWidget {
  final Client client;
  final int progressCount;
  const ProgressSummarySection({
    super.key,
    required this.client,
    required this.progressCount,
  });

  @override
  Widget build(BuildContext context) {
    return ClientSectionCard(
      children: [
        const ClientSectionTitle('Progress Summary'),
        const SizedBox(height: 16),
        MetricRow(label: 'Progress entries', value: progressCount.toString()),
        MetricRow(label: 'Weight trend', value: client.weightTrendLabel),
        MetricRow(label: 'Current BMI', value: client.bmiLabel),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showReport(context),
            icon: const Icon(Icons.description_outlined),
            label: const Text('Generate Report'),
          ),
        ),
      ],
    );
  }

  void _showReport(BuildContext context) {
    final report = _buildReport();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Progress Report'),
        content: SingleChildScrollView(child: SelectableText(report)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
          FilledButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: report));
              if (!dialogContext.mounted) return;
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Progress report copied.')),
              );
            },
            icon: const Icon(Icons.copy_outlined),
            label: const Text('Copy'),
          ),
        ],
      ),
    );
  }

  String _buildReport() {
    final entries = [...client.progressEntries]
      ..sort((a, b) => a.date.compareTo(b.date));
    final buffer = StringBuffer()
      ..writeln('FitEd Progress Report')
      ..writeln('Client: ${client.name}')
      ..writeln('Email: ${client.email}')
      ..writeln('Goal: ${client.goal}')
      ..writeln('Current BMI: ${client.bmiLabel}')
      ..writeln('Weight trend: ${client.weightTrendLabel}')
      ..writeln('Progress entries: $progressCount');

    if (entries.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('History');
      for (final entry in entries) {
        buffer.writeln(
          '${entry.dateLabel}: ${entry.weightKg.toStringAsFixed(1)} kg, '
          'BMI ${entry.bmi?.toStringAsFixed(1) ?? '--'}'
          '${entry.note.trim().isEmpty ? '' : ' - ${entry.note.trim()}'}',
        );
      }
    }

    return buffer.toString().trim();
  }
}
