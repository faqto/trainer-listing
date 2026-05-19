import 'package:flutter/material.dart';

import '../../models/activity_event.dart';
import '../../models/home_activity.dart';
import '../../pages/home/home_constants.dart';

class ActivityCard extends StatelessWidget {
  final HomeActivity activity;
  final ActivityEvent? event;

  const ActivityCard({super.key, required this.activity, this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
