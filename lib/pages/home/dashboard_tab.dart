import 'package:flutter/material.dart';

import '../../helpers/client_metrics.dart';
import '../../models/client_model.dart';
import '../../models/home_activity.dart';
import '../../widgets/home/activity_card.dart';
import '../../widgets/home/dashboard_metric.dart';
import '../../widgets/home/metric_divider.dart';
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
    final sessionsToday = clients.where(hasSessionToday).toList();
    final newClientsToday = clients
        .where((client) => isToday(client.joinDate))
        .length;

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
                    value: sessionsToday.length.toString(),
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
          // Today's sessions
          if (sessionsToday.isNotEmpty) ...[
            const SizedBox(height: 28),
            const Text(
              "Today's Sessions",
              style: TextStyle(
                color: inkColor,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Column(
              children: sessionsToday.map((client) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: space1),
                  child: _SessionClientCard(
                    client: client,
                    onEndSession: () => onOpenClient(client.id),
                  ),
                );
              }).toList(),
            ),
          ],
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
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'No activity yet.',
                style: TextStyle(color: mutedColor),
              ),
            )
          else
            Column(
              children: [
                for (final entry in recentActivity.indexed)
                  TweenAnimationBuilder<double>(
                    duration: Duration(milliseconds: 280 + entry.$1 * 80),
                    curve: Curves.easeOutCubic,
                    tween: Tween(begin: 0, end: 1),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 18 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: space1),
                      child: ActivityCard(
                        activity: entry.$2,
                        event: entry.$2.event,
                        onResolved: onActivityResolved,
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _SessionClientCard extends StatelessWidget {
  final Client client;
  final VoidCallback onEndSession;

  const _SessionClientCard({required this.client, required this.onEndSession});

  @override
  Widget build(BuildContext context) {
    final endTime = client.scheduledEndTime;
    final isActive =
        client.isSessionActive ||
        (client.scheduledEndTime != null &&
            DateTime.now().isAfter(client.scheduledEndTime!));

    String timeLabel = '';
    if (endTime != null) {
      final h = endTime.hour;
      final m = endTime.minute.toString().padLeft(2, '0');
      final period = h >= 12 ? 'PM' : 'AM';
      final hour12 = h % 12 == 0 ? 12 : h % 12;
      timeLabel = 'Ends $hour12:$m $period';
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: isActive ? const Color(0xFF10B981) : cardBorderColor,
          width: isActive ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: premiumCardShadows,
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFF10B981).withAlpha(30)
                  : const Color(0xFF1E40AF).withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isActive
                  ? Icons.play_circle_outline_rounded
                  : Icons.schedule_rounded,
              color: isActive
                  ? const Color(0xFF10B981)
                  : const Color(0xFF1E40AF),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  client.name,
                  style: const TextStyle(
                    color: inkColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  timeLabel.isNotEmpty ? timeLabel : client.schedule,
                  style: const TextStyle(color: mutedColor, fontSize: 12),
                ),
              ],
            ),
          ),
          if (isActive)
            FilledButton(
              onPressed: onEndSession,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'End',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
        ],
      ),
    );
  }
}
