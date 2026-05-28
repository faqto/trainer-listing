import 'package:flutter/material.dart';
import '../../../models/client_model.dart';
import '../client_section_card.dart';
import '../client_section_title.dart';

class NotesSection extends StatelessWidget {
  final Client client;
  const NotesSection({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return ClientSectionCard(
      children: [
        const ClientSectionTitle('Client Notes'),
        const SizedBox(height: 12),
        Text(client.notes.isEmpty ? 'No notes available.' : client.notes),
      ],
    );
  }
}
