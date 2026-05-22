import 'package:flutter/material.dart';

import '../../helpers/client_metrics.dart';
import '../../models/client_model.dart';
import '../../models/deletion_request.dart';
import '../../models/home_activity.dart';
import '../../widgets/home/activity_card.dart';
import '../../widgets/home/dashboard_metric.dart';
import '../../widgets/home/metric_divider.dart';
import '../../widgets/home/todays_sessions_section.dart';
import 'home_constants.dart';

class DashboardTab extends StatelessWidget {
  final List<Client> clients;
  final List<HomeActivity> recentActivity;
  final List<DeletionRequest> deletionRequests;
  final String trainerName;
  final VoidCallback onAddClient;
  final VoidCallback onActivityResolved;
  final Future<void> Function(String clientId) onOpenClient;
  final Future<void> Function(DeletionRequest request) onApproveDeletionRequest;
  final Future<void> Function(DeletionRequest request) onRejectDeletionRequest;

  const DashboardTab({
    super.key,
    required this.clients,
    required this.recentActivity,
    required this.deletionRequests,
    required this.trainerName,
    required this.onAddClient,
    required this.onActivityResolved,
    required this.onOpenClient,
    required this.onApproveDeletionRequest,
    required this.onRejectDeletionRequest,
  });

  @override
  Widget build(BuildContext context) {
    final newClientsToday = clients
        .where((client) => isToday(client.joinDate))
        .length;
    final todaysSessions = clients.where(hasSessionToday).toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(space2, 0, space2, 104),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: onAddClient,
                icon: const Icon(Icons.person_add_alt_1, size: 18),
                label: const Text('Add'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Metrics row
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: cardBorderColor),
              borderRadius: BorderRadius.circular(18),
              boxShadow: premiumCardShadows,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Row(
              children: [
                Expanded(
                  child: DashboardMetric(
                    label: 'Clients',
                    value: clients.length.toString(),
                    color: primaryColor,
                    icon: Icons.people_alt_rounded,
                  ),
                ),
                const MetricDivider(),
                Expanded(
                  child: DashboardMetric(
                    label: 'Sessions',
                    value: todaysSessions.length.toString(),
                    color: tealColor,
                    icon: Icons.event_available_rounded,
                  ),
                ),
                const MetricDivider(),
                Expanded(
                  child: DashboardMetric(
                    label: 'New',
                    value: newClientsToday.toString(),
                    color: roseColor,
                    icon: Icons.trending_up_rounded,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          TodaysSessionsSection(
            sessions: todaysSessions,
            onOpenClient: onOpenClient,
          ),
          const SizedBox(height: 28),
          _DeletionRequestsSection(
            requests: deletionRequests,
            onApprove: onApproveDeletionRequest,
            onReject: onRejectDeletionRequest,
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Recent Activity',
                  style: TextStyle(
                    color: inkColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '${recentActivity.length} total',
                style: const TextStyle(
                  color: mutedColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (recentActivity.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Text(
                  'No recent activity.',
                  style: TextStyle(color: mutedColor),
                ),
              ),
            )
          else
            ...recentActivity.map(
              (activity) => Padding(
                padding: const EdgeInsets.only(bottom: space1),
                child: ActivityCard(activity: activity),
              ),
            ),
        ],
      ),
    );
  }
}

class _DeletionRequestsSection extends StatefulWidget {
  final List<DeletionRequest> requests;
  final Future<void> Function(DeletionRequest request) onApprove;
  final Future<void> Function(DeletionRequest request) onReject;

  const _DeletionRequestsSection({
    required this.requests,
    required this.onApprove,
    required this.onReject,
  });

  @override
  State<_DeletionRequestsSection> createState() =>
      _DeletionRequestsSectionState();
}

class _DeletionRequestsSectionState extends State<_DeletionRequestsSection> {
  String? _processingId;

  Future<void> _process(
    DeletionRequest request,
    Future<void> Function(DeletionRequest request) action,
  ) async {
    if (_processingId != null) return;
    setState(() => _processingId = request.id);
    try {
      await action(request);
    } finally {
      if (mounted) setState(() => _processingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: cardBorderColor),
        borderRadius: BorderRadius.circular(18),
        boxShadow: premiumCardShadows,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Deletion Requests',
                  style: TextStyle(
                    color: inkColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '${widget.requests.length} pending',
                style: const TextStyle(
                  color: mutedColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (widget.requests.isEmpty)
            const Text(
              'No pending data deletion requests.',
              style: TextStyle(color: mutedColor),
            )
          else
            ...widget.requests.map((request) {
              final isProcessing = _processingId == request.id;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    border: Border.all(color: cardBorderColor),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.clientName.isEmpty
                              ? request.clientEmail
                              : request.clientName,
                          style: const TextStyle(
                            color: inkColor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (request.reason.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            request.reason,
                            style: const TextStyle(color: mutedColor),
                          ),
                        ],
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: isProcessing
                                    ? null
                                    : () => _process(request, widget.onReject),
                                child: const Text('Reject'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: FilledButton(
                                onPressed: isProcessing
                                    ? null
                                    : () => _process(request, widget.onApprove),
                                child: isProcessing
                                    ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text('Approve'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
