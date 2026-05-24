import 'package:flutter/material.dart';

import '../../../models/client_model.dart';
import '../client_section_card.dart';
import '../client_section_title.dart';
import 'detail_block.dart';

class ContactDetailsSection extends StatelessWidget {
  final Client client;

  const ContactDetailsSection({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return ClientSectionCard(
      children: [
        const ClientSectionTitle('Client Details'),
        const SizedBox(height: 12),
        DetailBlock(label: 'Email', value: client.email),
        DetailBlock(label: 'Phone', value: client.phone),
        DetailBlock(label: 'Goal', value: client.goal),
        if (client.clientUserId != null && client.clientUserId!.isNotEmpty)
          DetailBlock(label: 'Client Account ID', value: client.clientUserId!),
      ],
    );
  }
}
