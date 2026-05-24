import 'package:flutter/material.dart';
import 'package:fit_ed/widgets/clients/client_information_page/metric_row.dart';
import '../../../models/client_model.dart';
import '../client_section_card.dart';
import '../client_section_title.dart';

class BodyMetricsSection extends StatelessWidget {
  final Client client;
  const BodyMetricsSection({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return ClientSectionCard(
      children: [
        const ClientSectionTitle('Body Metrics'),
        const SizedBox(height: 16),
        MetricRow(
          label: 'Weight',
          value: '${client.weightKg.toStringAsFixed(1)} kg',
        ),
        MetricRow(
          label: 'Height',
          value: '${client.heightCm.toStringAsFixed(1)} cm',
        ),
        MetricRow(label: 'BMI', value: client.bmiLabel),
        MetricRow(
          label: 'Body Fat',
          value: '${client.bodyFatPercent.toStringAsFixed(1)}%',
        ),
        MetricRow(
          label: 'Waist',
          value: '${client.waistCm.toStringAsFixed(1)} cm',
        ),
        MetricRow(
          label: 'Hips',
          value: '${client.hipsCm.toStringAsFixed(1)} cm',
        ),
        MetricRow(
          label: 'Chest',
          value: '${client.chestCm.toStringAsFixed(1)} cm',
        ),
      ],
    );
  }
}
