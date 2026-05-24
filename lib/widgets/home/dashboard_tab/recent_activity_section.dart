import 'package:fit_ed/models/home_activity.dart';
import 'package:fit_ed/pages/home/home_constants.dart';
import 'package:fit_ed/widgets/home/activity_card.dart';
import 'package:flutter/material.dart';

class RecentActivitySection extends StatelessWidget {
  final List<HomeActivity> activities;
  final VoidCallback onActivityResolved;

  const RecentActivitySection({
    super.key,
    required this.activities,
    required this.onActivityResolved,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              '${activities.length} total',
              style: const TextStyle(
                color: mutedColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (activities.isEmpty)
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
          ...activities.map(
            (activity) => Padding(
              padding: const EdgeInsets.only(bottom: space1),
              child: ActivityCard(activity: activity),
            ),
          ),
      ],
    );
  }
}
