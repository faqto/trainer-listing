import 'package:flutter/material.dart';

import '../../models/client_model.dart';
import '../../widgets/home/plan_card.dart';
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
          child: PlanCard(client: client, onOpenClient: onOpenClient),
        );
      },
    );
  }
}
