import 'package:flutter/material.dart';

import '../../helpers/client_metrics.dart';
import '../../models/client_model.dart';
import '../../models/home_activity.dart';
import '../../widgets/home/activity_card.dart';
import '../../widgets/home/dashboard_metric.dart';
import '../../widgets/home/metric_divider.dart';
import '../../widgets/home/todays_sessions_section.dart';
import 'home_constants.dart';

class DashboardTab extends StatelessWidget {
  final List<Client> clients;
  final List<HomeActivity> recentActivity;
  final String trainerName;
  final VoidCallback onAddClient;
  final VoidCallback onActivityResolved;
  final Future<void> Function(String clientId) onOpenClient;

  const DashboardTab({
    super.key,
    required this.clients,
    required this.recentActivity,
    required this.trainerName,
    required this.onAddClient,
    required this.onActivityResolved,
    required this.onOpenClient,
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
