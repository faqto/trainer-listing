import 'package:FitEd/widgets/client/client_information_page/metric_row.dart';
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
      ],
    );
  }
}
