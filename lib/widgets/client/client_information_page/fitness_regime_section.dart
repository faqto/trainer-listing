import 'package:flutter/material.dart';
import 'package:FitEd/widgets/client/client_information_page/detail_block.dart';
import '../../../models/client_model.dart';
import '../../../routes/app_routes.dart';
import '../../../helpers/navigation_helper.dart';
import '../../../widgets/client/client_section_card.dart';
import '../../../widgets/client/client_section_title.dart';

class FitnessRegimeSection extends StatelessWidget {
  final Client client;
  final Future<void> Function() onRefresh;
  const FitnessRegimeSection({
    super.key,
    required this.client,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return ClientSectionCard(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const ClientSectionTitle('Fitness Regime'),
            TextButton(
              onPressed: () => NavigationHelper.navigateAndRefresh(
                context: context,
                routeName: AppRoutes.editRegime,
                onRefresh: onRefresh,
                arguments: client.id,
              ),
              child: const Text('Edit'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        DetailBlock(label: 'Schedule', value: client.schedule),
        DetailBlock(label: 'Workout', value: client.fitnessRegime),
        DetailBlock(label: 'Cardio', value: client.cardioPlan),
      ],
    );
  }
}
