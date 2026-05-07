import 'package:flutter/material.dart';

class ClientsListPage extends StatelessWidget {
  const ClientsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clients')),
      body: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text('Client ${index + 1}'),
            subtitle: const Text('Tap to view details'),
            onTap: () {},
          );
        },
      ),
    );
  }
}
