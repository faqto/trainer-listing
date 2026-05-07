import 'package:flutter/material.dart';

import '../../models/client_model.dart';
import '../../routes/app_routes.dart';
import '../../services/client_repository.dart';

class ClientInformationPage extends StatefulWidget {
  final String clientId;

  const ClientInformationPage({super.key, required this.clientId});

  @override
  State<ClientInformationPage> createState() => _ClientInformationPageState();
}

class _ClientInformationPageState extends State<ClientInformationPage> {
  Client? _client;

  void _loadClient() {
    _client = ClientRepository.instance.getById(widget.clientId);
  }

  Future<void> _refresh() async {
    setState(_loadClient);
  }

  @override
  void initState() {
    super.initState();
    _loadClient();
  }

  @override
  Widget build(BuildContext context) {
    if (_client == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Client Profile')),
        body: const Center(child: Text('Client not found.')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFEFF5FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF13294B),
        title: const Text('Client Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_client!.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(_client!.trainingProgram, style: const TextStyle(color: Colors.black54)),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _InfoBadge(label: '${_client!.age} yrs'),
                      _InfoBadge(label: _client!.gender),
                      _InfoBadge(label: _client!.schedule),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Body Metrics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _metricRow('Weight', '${_client!.weightKg.toStringAsFixed(1)} kg'),
                  _metricRow('Height', '${_client!.heightCm.toStringAsFixed(1)} cm'),
                  _metricRow('Body Fat', '${_client!.bodyFatPercent.toStringAsFixed(1)}%'),
                  _metricRow('Waist', '${_client!.waistCm.toStringAsFixed(1)} cm'),
                  _metricRow('Hips', '${_client!.hipsCm.toStringAsFixed(1)} cm'),
                  _metricRow('Chest', '${_client!.chestCm.toStringAsFixed(1)} cm'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Client Notes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(_client!.notes.isEmpty ? 'No notes available.' : _client!.notes),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.pushNamed(context, AppRoutes.editClient, arguments: _client!.id);
                if (result == true) {
                  await _refresh();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF13294B),
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Edit Client'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () async {
                final result = await Navigator.pushNamed(context, AppRoutes.bodyDetails, arguments: _client!.id);
                if (result == true) {
                  await _refresh();
                }
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Update Body Metrics'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final String label;

  const _InfoBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: const Color(0xFFEAF3FF), borderRadius: BorderRadius.circular(16)),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}
