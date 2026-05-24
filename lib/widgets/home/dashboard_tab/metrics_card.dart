import 'package:fit_ed/pages/home/home_constants.dart';
import 'package:fit_ed/widgets/home/dashboard_metric.dart';
import 'package:fit_ed/widgets/home/metric_divider.dart';
import 'package:flutter/material.dart';

class MetricsCard extends StatelessWidget {
  final int clientsCount;
  final int todaysSessionsCount;
  final int newClientsTodayCount;

  const MetricsCard({
    super.key,
    required this.clientsCount,
    required this.todaysSessionsCount,
    required this.newClientsTodayCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
              value: clientsCount.toString(),
              color: primaryColor,
              icon: Icons.people_alt_rounded,
            ),
          ),
          const MetricDivider(),
          Expanded(
            child: DashboardMetric(
              label: 'Sessions',
              value: todaysSessionsCount.toString(),
              color: tealColor,
              icon: Icons.event_available_rounded,
            ),
          ),
          const MetricDivider(),
          Expanded(
            child: DashboardMetric(
              label: 'New',
              value: newClientsTodayCount.toString(),
              color: roseColor,
              icon: Icons.trending_up_rounded,
            ),
          ),
        ],
      ),
    );
  }
}
