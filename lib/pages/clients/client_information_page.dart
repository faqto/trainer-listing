import 'package:flutter/material.dart';

import '../../models/client_model.dart';
import '../../routes/app_routes.dart';
import '../../services/client_repository.dart';
import '../../widgets/client_information_page/detail_block.dart';
import '../../widgets/client_information_page/info_badge.dart';
import '../../widgets/client_information_page/metric_row.dart';
import '../../widgets/client_information_page/progress_entry_card.dart';
import '../../widgets/client_section_card.dart';
import '../../widgets/client_section_title.dart';
import '../../widgets/client_sliver_app_bar.dart';
import '../home/home_constants.dart';
import '../../helpers/client_page_helpers.dart';

class ClientInformationPage extends StatefulWidget {
  final String clientId;

  const ClientInformationPage({super.key, required this.clientId});

  @override
  State<ClientInformationPage> createState() => _ClientInformationPageState();
}

class _ClientInformationPageState extends State<ClientInformationPage> {
  Client? _client;

  @override
  void initState() {
    super.initState();
    _loadClient();
  }

  Future<void> _loadClient() async {
    _client = await ClientRepository.instance.getById(widget.clientId);
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _refresh() async {
    await _loadClient();
  }

  @override
  Widget build(BuildContext context) {
    if (_client == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Client Profile')),
        body: const Center(child: Text('Client not found.')),
      );
    }

    final progressEntries = [..._client!.progressEntries]
      ..sort((a, b) => b.date.compareTo(a.date));

    final builder = _ClientInfoBuilder(
      client: _client!,
      progressEntries: progressEntries,
      onRefresh: _refresh,
      context: context,
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.pop(context, true);
      },
      child: Scaffold(
        backgroundColor: clientPageBackgroundColor,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [builder.buildAppBar(), builder.buildBody()],
        ),
      ),
    );
  }
}

class _ClientInfoBuilder {
  final Client client;
  final List<ProgressEntry> progressEntries;
  final Future<void> Function() onRefresh;
  final BuildContext context;

  const _ClientInfoBuilder({
    required this.client,
    required this.progressEntries,
    required this.onRefresh,
    required this.context,
  });

  Widget buildAppBar() {
    return ClientSliverAppBar(
      name: client.name,
      goal: client.goal,
      clientId: client.id,
      onBack: () => Navigator.pop(context, true),
    );
  }

  Widget buildBody() {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(space2, space1, space2, space3),
      sliver: SliverList.list(
        children: [
          _buildInfoBadgesCard(),
          clientSectionGap,
          _buildFitnessRegimeCard(),
          clientSectionGap,
          _buildBodyMetricsCard(),
          clientSectionGap,
          _buildProgressSummaryCard(),
          clientSectionGap,
          _buildProgressHistoryCard(),
          clientSectionGap,
          _buildNotesCard(),
          const SizedBox(height: 24),
          _buildEditClientButton(),
          const SizedBox(height: 12),
          _buildUpdateBodyMetricsButton(),
        ],
      ),
    );
  }

  Widget _buildInfoBadgesCard() {
    return ClientSectionCard(
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            InfoBadge(label: '${client.age} yrs'),
            InfoBadge(label: client.gender),
            InfoBadge(label: client.schedule),
          ],
        ),
      ],
    );
  }

  Widget _buildFitnessRegimeCard() {
    return ClientSectionCard(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const ClientSectionTitle('Fitness Regime'),
            TextButton(
              onPressed: () async {
                final result = await Navigator.pushNamed(
                  context,
                  AppRoutes.editRegime,
                  arguments: client.id,
                );
                if (result == true) await onRefresh();
              },
              child: const Text('Edit'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        DetailBlock(label: 'Schedule', value: client.schedule),
        DetailBlock(label: 'Workout', value: client.fitnessRegime),
        DetailBlock(label: 'Cardio', value: client.cardioPlan),
      ],
    );
  }

  Widget _buildBodyMetricsCard() {
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

  Widget _buildProgressSummaryCard() {
    return ClientSectionCard(
      children: [
        const ClientSectionTitle('Progress Summary'),
        const SizedBox(height: 16),
        MetricRow(
          label: 'Progress entries',
          value: progressEntries.length.toString(),
        ),
        MetricRow(label: 'Weight trend', value: client.weightTrendLabel),
        MetricRow(label: 'Current BMI', value: client.bmiLabel),
      ],
    );
  }

  Widget _buildProgressHistoryCard() {
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

  Widget _buildNotesCard() {
    return ClientSectionCard(
      children: [
        const ClientSectionTitle('Client Notes'),
        const SizedBox(height: 12),
        Text(client.notes.isEmpty ? 'No notes available.' : client.notes),
      ],
    );
  }

  Widget _buildEditClientButton() {
    return ElevatedButton(
      onPressed: () async {
        final result = await Navigator.pushNamed(
          context,
          AppRoutes.editClient,
          arguments: client.id,
        );
        if (result == true) await onRefresh();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF13294B),
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: const Text('Edit Client'),
    );
  }

  Widget _buildUpdateBodyMetricsButton() {
    return OutlinedButton(
      onPressed: () async {
        final result = await Navigator.pushNamed(
          context,
          AppRoutes.bodyDetails,
          arguments: client.id,
        );
        if (result == true) await onRefresh();
      },
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: const Text('Update Body Metrics'),
    );
  }
}
