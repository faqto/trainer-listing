import 'package:flutter/material.dart';
import '../../models/client_model.dart';
import '../../pages/home/home_constants.dart';

class TodaysSessionsSection extends StatelessWidget {
  final List<Client> sessions;
  final Future<void> Function(String clientId) onOpenClient;

  const TodaysSessionsSection({
    super.key,
    required this.sessions,
    required this.onOpenClient,
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
                "Today's Sessions",
                style: TextStyle(
                  color: inkColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              '${sessions.length} scheduled',
              style: const TextStyle(
                color: mutedColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (sessions.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'No sessions scheduled for today.',
                style: TextStyle(color: mutedColor),
              ),
            ),
          )
        else
          ...sessions.map(
            (client) => Padding(
              padding: const EdgeInsets.only(bottom: space1),
              child: _SessionTile(client: client, onTap: onOpenClient),
            ),
          ),
      ],
    );
  }
}

class _SessionTile extends StatelessWidget {
  final Client client;
  final Future<void> Function(String clientId) onTap;

  const _SessionTile({required this.client, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(client.id),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: cardBorderColor),
          borderRadius: BorderRadius.circular(14),
          boxShadow: premiumCardShadows,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: tealColor.withAlpha((0.10 * 255).round()),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.fitness_center_rounded,
                color: tealColor,
                size: 20,
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
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  if (client.schedule.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      client.schedule,
                      style: const TextStyle(
                        color: mutedColor,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: mutedColor, size: 20),
          ],
        ),
      ),
    );
  }
}
