import 'package:flutter/material.dart';

import '../../models/client_model.dart';
import 'home_constants.dart';
import 'home_models.dart';

class DashboardTab extends StatelessWidget {
  final List<Client> clients;
  final List<HomeActivity> recentActivity;
  final VoidCallback onAddClient;

  const DashboardTab({
    super.key,
    required this.clients,
    required this.recentActivity,
    required this.onAddClient,
  });

  @override
  Widget build(BuildContext context) {
    final averageBmi = _averageBmi(clients);
    final sessionsToday = clients.where(_hasSessionToday).length;
    final newClientsToday = clients
        .where((client) => _isToday(client.joinDate))
        .length;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(space2, space2, space2, 104),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Coach Ed',
            style: TextStyle(
              color: inkColor,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Today at a glance',
            style: TextStyle(color: mutedColor, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _DashboardMetricCard(
                label: 'Active Clients',
                value: clients.length.toString(),
                color: primaryColor,
              ),
              _DashboardMetricCard(
                label: 'Sessions Today',
                value: sessionsToday.toString(),
                color: tealColor,
              ),
              _DashboardMetricCard(
                label: 'Avg. BMI',
                value: averageBmi,
                color: amberColor,
              ),
              _DashboardMetricCard(
                label: 'New Clients',
                value: newClientsToday.toString(),
                color: roseColor,
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onAddClient,
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Add Client'),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Recent Activity',
            style: TextStyle(
              color: inkColor,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
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

  String _averageBmi(List<Client> clients) {
    final bmiValues = clients
        .where((client) => client.weightKg > 0 && client.heightCm > 0)
        .map(
          (client) =>
              client.weightKg /
              ((client.heightCm / 100) * (client.heightCm / 100)),
        )
        .toList();

    if (bmiValues.isEmpty) return '--';

    final total = bmiValues.reduce((value, element) => value + element);
    return (total / bmiValues.length).toStringAsFixed(1);
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

class _DashboardMetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _DashboardMetricCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.43,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: cardBorderColor),
        borderRadius: BorderRadius.circular(16),
        boxShadow: premiumCardShadows,
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 10,
                width: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: mutedColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              color: inkColor,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
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
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: activity.color.withAlpha((0.12 * 255).round()),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(activity.icon, color: activity.color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.name,
                  style: const TextStyle(
                    color: inkColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: mutedColor),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            activity.time,
            style: const TextStyle(
              color: mutedColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
