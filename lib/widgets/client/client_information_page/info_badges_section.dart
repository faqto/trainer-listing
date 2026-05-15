import 'package:flutter/material.dart';
import 'package:trainer_listing/widgets/client/client_information_page/info_badge.dart';
import '../../../models/client_model.dart';
import '../../../widgets/client/client_section_card.dart';

class InfoBadgesSection extends StatelessWidget {
  final Client client;
  const InfoBadgesSection({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return ClientSectionCard(
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            InfoBadge(label: '${client.age} yrs'),
            InfoBadge(label: client.sex),
            InfoBadge(label: client.schedule),
          ],
        ),
      ],
    );
  }
}
