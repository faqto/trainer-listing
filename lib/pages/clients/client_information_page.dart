import 'package:flutter/material.dart';
import 'package:trainer_listing/helpers/client_page_helpers.dart';
import 'package:trainer_listing/widgets/client/client_information_page/action_buttons.dart';
import 'package:trainer_listing/widgets/client/client_information_page/body_metrics_section.dart';
import 'package:trainer_listing/widgets/client/client_information_page/fitness_regime_section.dart';
import 'package:trainer_listing/widgets/client/client_information_page/info_badges_section.dart';
import 'package:trainer_listing/widgets/client/client_information_page/notes_section.dart';
import 'package:trainer_listing/widgets/client/client_information_page/progress_history_section.dart';
import 'package:trainer_listing/widgets/client/client_information_page/progress_summary_section.dart';
import 'package:trainer_listing/widgets/shared/page_error_view.dart';
import '../../models/client_model.dart';
import '../../services/client_repository.dart';
import '../../widgets/client/client_sliver_app_bar.dart';

class ClientInformationPage extends StatefulWidget {
  final String clientId;
  const ClientInformationPage({super.key, required this.clientId});

  @override
  State<ClientInformationPage> createState() => _ClientInformationPageState();
}

class _ClientInformationPageState extends State<ClientInformationPage> {
  Client? _client;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadClient();
  }

  Future<void> _loadClient() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      _client = await ClientRepository.instance.getById(widget.clientId);
      // If the client no longer exists (e.g. just deleted), go back immediately.
      if (mounted && _client == null) {
        Navigator.pop(context, true);
        return;
      }
    } catch (e) {
      debugPrint(e.toString());
      _errorMessage = 'Failed to load client data.';
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _refresh() async => _loadClient();

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_client == null || _errorMessage != null) {
      return PageErrorView(
        title: 'Client Profile',
        errorMessage: _errorMessage ?? 'Client not found.',
        onRetry: _loadClient,
        showBackButton: true,
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.pop(context, true);
      },
      child: Scaffold(
        backgroundColor: clientPageBackgroundColor,
        body: RefreshIndicator(
          onRefresh: _refresh,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              ClientSliverAppBar(
                name: _client!.name,
                goal: _client!.goal,
                clientId: _client!.id,
                onBack: () => Navigator.pop(context, true),
              ),
              _buildBody(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    final progressEntries = [..._client!.progressEntries]
      ..sort((a, b) => b.date.compareTo(a.date));

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      sliver: SliverList.list(
        children: [
          InfoBadgesSection(client: _client!),
          const SizedBox(height: 16),
          FitnessRegimeSection(client: _client!, onRefresh: _refresh),
          const SizedBox(height: 16),
          BodyMetricsSection(client: _client!),
          const SizedBox(height: 16),
          ProgressSummarySection(
            client: _client!,
            progressCount: progressEntries.length,
          ),
          const SizedBox(height: 16),
          ProgressHistorySection(
            progressEntries: progressEntries,
            clientId: _client!.id, // Add this
            onRefresh: _refresh, // Add this
          ),
          const SizedBox(height: 16),
          NotesSection(client: _client!),
          const SizedBox(height: 24),
          ActionButtons(clientId: _client!.id, onRefresh: _refresh),
        ],
      ),
    );
  }
}
