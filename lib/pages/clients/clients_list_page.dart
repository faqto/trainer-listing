import 'package:flutter/material.dart';

import '../../models/client_model.dart';
import '../../routes/app_routes.dart';
import '../../services/client_repository.dart';

class ClientsListPage extends StatefulWidget {
  const ClientsListPage({super.key});

  @override
  State<ClientsListPage> createState() => _ClientsListPageState();
}

class _ClientsListPageState extends State<ClientsListPage> {
  late List<Client> _clients;

  void _refreshClients() {
    setState(() {
      _clients = ClientRepository.instance.clients;
    });
  }

  Future<void> _openClientDetails(String clientId) async {
    final result = await Navigator.pushNamed(context, AppRoutes.clientInfo, arguments: clientId);
    if (result == true) {
      _refreshClients();
    }
  }

  @override
  void initState() {
    super.initState();
    _clients = ClientRepository.instance.clients;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Clients',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
      body: _clients.isEmpty
          ? const Center(child: Text('No clients yet. Add a client to get started.'))
          : ListView.separated(
              itemCount: _clients.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final client = _clients[index];
                return Container(
                  color: Colors.white,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF13294B),
                      child: Text(
                        client.name.isEmpty ? '?' : client.name[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      client.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    subtitle: Text(
                      client.goal,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) {
                            return AlertDialog(
                              title: const Text('Delete Client'),
                              content: Text('Delete ${client.name}?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
                                TextButton(
                                  onPressed: () {
                                    ClientRepository.instance.deleteClient(client.id);
                                    Navigator.of(ctx).pop();
                                    _refreshClients();
                                  },
                                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    onTap: () => _openClientDetails(client.id),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, AppRoutes.addClient);
          if (result == true) {
            _refreshClients();
          }
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
