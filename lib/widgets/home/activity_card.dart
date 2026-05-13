import 'package:flutter/material.dart';

import '../../models/activity_event.dart';
import '../../models/home_activity.dart';
import '../../pages/home/home_constants.dart';
import '../../services/activity_repository.dart';

class ActivityCard extends StatelessWidget {
  final HomeActivity activity;
  final ActivityEvent? event;
  final VoidCallback? onResolved;

  const ActivityCard({
    super.key,
    required this.activity,
    this.event,
    this.onResolved,
  });

  @override
  Widget build(BuildContext context) {
    final isMissed = event?.isMissedUnresolved ?? false;

    return Container(
      decoration: BoxDecoration(
        color: isMissed ? const Color(0xFFFFFBEB) : Colors.white,
        border: Border.all(
          color: isMissed ? const Color(0xFFFCD34D) : cardBorderColor,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: premiumCardShadows,
      ),
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
                    const SizedBox(height: 5),
                    Text(
                      activity.subtitle,
                      maxLines: isMissed ? 2 : 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: mutedColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isMissed) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _resolve(context, 'completed'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF10B981),
                      side: const BorderSide(color: Color(0xFF10B981)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Completed',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _resolve(context, 'missed'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444),
                      side: const BorderSide(color: Color(0xFFEF4444)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Client missed it',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _resolve(BuildContext context, String outcome) async {
    if (event == null) return;
    await ActivityRepository.instance.resolveMissedSession(event!, outcome);
    onResolved?.call();
  }
}
