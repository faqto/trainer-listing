import 'package:flutter/material.dart';
import 'package:trainer_listing/models/client_model.dart';

class ActivityTile extends StatelessWidget {
  final ClientModel client;
  final VoidCallback? onTap;

  const ActivityTile({super.key, required this.client, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),

      child: ListTile(
        onTap: onTap,

        leading: CircleAvatar(child: Text(client.name[0])),

        title: Text(
          client.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

        subtitle: Text(client.date),

        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${client.weight} kg',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(width: 2),

            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
