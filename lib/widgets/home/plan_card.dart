import 'package:flutter/material.dart';

import '../../models/client_model.dart';
import '../../pages/home/home_constants.dart';
import 'plan_line.dart';
import 'pressable_scale.dart';

class PlanCard extends StatelessWidget {
  final Client client;
  final ValueChanged<String> onOpenClient;

  const PlanCard({super.key, required this.client, required this.onOpenClient});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 0, end: 1),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 24 * (1 - value)),
            child: child,
          ),
        );
      },
      child: PressableScale(
        onTap: () => onOpenClient(client.id),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: cardBorderColor),
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Color(0xFFF1F5F9)],
            ),
            boxShadow: premiumCardShadows,
          ),
          padding: const EdgeInsets.all(space2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Hero(
                    tag: 'client-avatar-${client.id}',
                    child: Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [primaryColor, tealColor],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.fitness_center,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          client.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: inkColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          client.goal,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: mutedColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: mutedColor),
                ],
              ),
              const SizedBox(height: 14),
              PlanLine(
                icon: Icons.event_available_outlined,
                label: 'Schedule',
                text: client.schedule.isEmpty
                    ? 'Schedule not set'
                    : client.schedule,
              ),
              const SizedBox(height: 8),
              PlanLine(
                icon: Icons.list_alt,
                label: 'Workout',
                text: client.fitnessRegime.isEmpty
                    ? 'Workout regime not set'
                    : client.fitnessRegime,
              ),
              const SizedBox(height: 8),
              PlanLine(
                icon: Icons.directions_run,
                label: 'Cardio',
                text: client.cardioPlan.isEmpty
                    ? 'Cardio plan not set'
                    : client.cardioPlan,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
