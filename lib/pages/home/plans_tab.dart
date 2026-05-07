import 'package:flutter/material.dart';

import '../../models/client_model.dart';
import 'clients_tab.dart';
import 'home_constants.dart';

class PlansTab extends StatelessWidget {
  final List<Client> clients;
  final ValueChanged<String> onOpenClient;

  const PlansTab({
    super.key,
    required this.clients,
    required this.onOpenClient,
  });

  @override
  Widget build(BuildContext context) {
    if (clients.isEmpty) {
      return const Center(child: Text('No client plans yet.'));
    }

    return PageView.builder(
      controller: PageController(viewportFraction: 0.9),
      physics: const BouncingScrollPhysics(),
      padEnds: false,
      itemCount: clients.length,
      itemBuilder: (context, index) {
        final client = clients[index];
        return Padding(
          padding: EdgeInsets.fromLTRB(
            index == 0 ? space2 : space1,
            space2,
            space1,
            104,
          ),
          child: _PlanCard(client: client, onOpenClient: onOpenClient),
        );
      },
    );
  }
}

class _PlanCard extends StatelessWidget {
  final Client client;
  final ValueChanged<String> onOpenClient;

  const _PlanCard({required this.client, required this.onOpenClient});

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
                          style: const TextStyle(
                            color: inkColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          client.goal,
                          style: const TextStyle(
                            color: mutedColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: mutedColor),
                ],
              ),
              const SizedBox(height: 14),
              _PlanLine(
                icon: Icons.event_available_outlined,
                text: client.schedule.isEmpty
                    ? 'Schedule not set'
                    : client.schedule,
              ),
              const SizedBox(height: 8),
              _PlanLine(
                icon: Icons.list_alt,
                text: client.fitnessRegime.isEmpty
                    ? 'Workout regime not set'
                    : client.fitnessRegime,
              ),
              const SizedBox(height: 8),
              _PlanLine(
                icon: Icons.directions_run,
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

class _PlanLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const _PlanLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: mutedColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: inkColor,
              fontWeight: FontWeight.w600,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
