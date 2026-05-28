import 'package:fit_ed/helpers/client_form_validators.dart';
import 'package:flutter/material.dart';

import 'section_card.dart';

class BodyMetricsSection extends StatelessWidget {
  final TextEditingController weightController;
  final TextEditingController heightController;
  final TextEditingController bodyFatController;
  final TextEditingController waistController;
  final TextEditingController hipsController;
  final TextEditingController chestController;

  const BodyMetricsSection({
    super.key,
    required this.weightController,
    required this.heightController,
    required this.bodyFatController,
    required this.waistController,
    required this.hipsController,
    required this.chestController,
  });

  Widget _metricField({
    required TextEditingController controller,
    required String label,
    required String validationLabel,
    bool required = false,
    double? max,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (value) =>
          validateMetric(value, validationLabel, required: required, max: max),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Body Metrics',
      icon: Icons.monitor_weight_outlined,
      children: [
        Row(
          children: [
            Expanded(
              child: _metricField(
                controller: weightController,
                label: 'Weight (kg)',
                validationLabel: 'weight',
                required: true,
                max: 500,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _metricField(
                controller: heightController,
                label: 'Height (cm)',
                validationLabel: 'height',
                required: true,
                max: 300,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _metricField(
                controller: bodyFatController,
                label: 'Body Fat (%)',
                validationLabel: 'body fat',
                max: 100,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _metricField(
                controller: waistController,
                label: 'Waist (cm)',
                validationLabel: 'waist',
                max: 300,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _metricField(
                controller: hipsController,
                label: 'Hips (cm)',
                validationLabel: 'hips',
                max: 300,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _metricField(
                controller: chestController,
                label: 'Chest (cm)',
                validationLabel: 'chest',
                max: 300,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
