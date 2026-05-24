import 'package:fit_ed/widgets/clients/client_information_page/progress_entry_card.dart';
import 'package:flutter/material.dart';
import '../../../models/client_model.dart';
import '../client_section_card.dart';
import '../client_section_title.dart';

class ProgressHistorySection extends StatelessWidget {
  final List<ProgressEntry> progressEntries;
  final String clientId;
  final Future<void> Function() onRefresh;

  const ProgressHistorySection({
    super.key,
    required this.progressEntries,
    required this.clientId,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return ClientSectionCard(
      children: [
        const ClientSectionTitle('Progress History'),
        const SizedBox(height: 12),
        if (progressEntries.isEmpty)
          const Text('No progress entries yet.')
        else
          ...progressEntries.map((e) => ProgressEntryCard(entry: e)),
      ],
    );
  }
}
