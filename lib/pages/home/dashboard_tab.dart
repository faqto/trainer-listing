import 'package:flutter/material.dart';

import '../../models/client_model.dart';
import 'home_constants.dart';
import 'home_models.dart';

class DashboardTab extends StatelessWidget {
  final List<Client> clients;
  final List<HomeActivity> recentActivity;
  final String trainerName;
  final VoidCallback onAddClient;

  const DashboardTab({
    super.key,
    required this.clients,
    required this.recentActivity,
    required this.trainerName,
    required this.onAddClient,
  });

  @override
  Widget build(BuildContext context) {
    final sessionsToday = clients.where(_hasSessionToday).length;
    final newClientsToday = clients
        .where((client) => _isToday(client.joinDate))
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
                    SizedBox(height: 6),
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
                  child: _DashboardMetric(
                    label: 'Clients',
                    value: clients.length.toString(),
                    color: primaryColor,
                    icon: Icons.people_alt_rounded,
                  ),
                ),
                const _MetricDivider(),
                Expanded(
                  child: _DashboardMetric(
                    label: 'Sessions',
                    value: sessionsToday.toString(),
                    color: tealColor,
                    icon: Icons.event_available_rounded,
                  ),
                ),
                const _MetricDivider(),
                Expanded(
                  child: _DashboardMetric(
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
                    child: _ActivityCard(activity: entry.$2),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  bool _hasSessionToday(Client client) {
    if (client.schedule.trim().isEmpty) return false;

    final weekday = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ][DateTime.now().weekday - 1];
    return client.schedule.toLowerCase().contains(weekday.toLowerCase());
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}

class _DashboardMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _DashboardMetric({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 36,
          width: 36,
          decoration: BoxDecoration(
            color: color.withAlpha((0.10 * 255).round()),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 19),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: const TextStyle(
            color: inkColor,
            fontSize: 26,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: mutedColor,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _MetricDivider extends StatelessWidget {
  const _MetricDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: cardBorderColor,
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final HomeActivity activity;

  const _ActivityCard({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: cardBorderColor),
        borderRadius: BorderRadius.circular(16),
        boxShadow: premiumCardShadows,
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: activity.color.withAlpha((0.12 * 255).round()),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(activity.icon, color: activity.color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        activity.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: inkColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      activity.time,
                      style: const TextStyle(
                        color: mutedColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  activity.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: mutedColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
