import 'package:flutter/material.dart';

import '../../models/client_model.dart';
import '../../pages/home/home_constants.dart';
import 'pressable_scale.dart';
import 'status_badge.dart';

class ClientCard extends StatelessWidget {
  final Client client;
  final int index;
  final ValueChanged<String> onOpenClient;

  const ClientCard({
    super.key,
    required this.client,
    required this.index,
    required this.onOpenClient,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 70).clamp(0, 360)),
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 0, end: 1),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 26 * (1 - value)),
            child: child,
          ),
        );
      },
      child: PressableScale(
        onTap: () => onOpenClient(client.id),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: cardBorderColor),
            borderRadius: BorderRadius.circular(20),
            boxShadow: premiumCardShadows,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          primaryColor.withAlpha(28),
                          tealColor.withAlpha(20),
                          Colors.white,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(28),
                    ),
                    child: Container(
                      height: 72,
                      width: 116,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            primaryColor.withAlpha(210),
                            tealColor.withAlpha(195),
                          ],
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withAlpha(54),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const Center(
                            child: Icon(
                              Icons.fitness_center,
                              color: Colors.white70,
                              size: 34,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(space2),
                  child: Row(
                    children: [
                      Hero(
                        tag: 'client-avatar-${client.id}',
                        child: CircleAvatar(
                          radius: 28,
                          backgroundColor: primaryColor,
                          child: Text(
                            client.name.isEmpty ? '?' : client.name[0],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: space2),
                      Expanded(
                        child: Hero(
                          tag: 'client-title-${client.id}',
                          child: Material(
                            color: Colors.transparent,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  client.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: inkColor,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 17,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  client.goal,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: inkColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  client.schedule.trim().isEmpty
                                      ? 'Schedule not set'
                                      : client.schedule,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: mutedColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: space1),
                                Wrap(
                                  spacing: space1,
                                  runSpacing: space1,
                                  children: [
                                    StatusBadge(
                                      label: client.sex,
                                      color: primaryColor,
                                    ),
                                    StatusBadge(
                                      label: '${client.age} yrs',
                                      color: amberColor,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 18,
                        color: Colors.black26,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
