import 'package:fit_ed/widgets/home/dashboard_tab/dashboard_header.dart';
import 'package:fit_ed/widgets/home/dashboard_tab/deletion_requests_section.dart';
import 'package:fit_ed/widgets/home/dashboard_tab/metrics_card.dart';
import 'package:fit_ed/widgets/home/dashboard_tab/recent_activity_section.dart';
import 'package:fit_ed/widgets/home/todays_sessions_section.dart';
import 'package:flutter/material.dart';

import '../../helpers/client_metrics.dart';
import '../../models/client_model.dart';
import '../../models/deletion_request.dart';
import '../../models/home_activity.dart';
import 'home_constants.dart';

class DashboardTab extends StatelessWidget {
  final List<Client> clients;
  final List<HomeActivity> recentActivity;
  final List<DeletionRequest> deletionRequests;
  final String trainerName;
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
          DashboardHeader(trainerName: trainerName),
          const SizedBox(height: 24),
          MetricsCard(
            clientsCount: clients.length,
            todaysSessionsCount: todaysSessions.length,
            newClientsTodayCount: newClientsToday,
          ),
          const SizedBox(height: 28),
          TodaysSessionsSection(
            sessions: todaysSessions,
            onOpenClient: onOpenClient,
          ),
          const SizedBox(height: 28),
          DeletionRequestsSection(
            requests: deletionRequests,
            onApprove: onApproveDeletionRequest,
            onReject: onRejectDeletionRequest,
          ),
          const SizedBox(height: 28),
          RecentActivitySection(
            activities: recentActivity,
            onActivityResolved: onActivityResolved,
          ),
        ],
      ),
    );
  }
}
