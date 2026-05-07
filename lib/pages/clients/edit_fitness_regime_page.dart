import 'package:flutter/material.dart';

import '../../models/client_model.dart';
import '../../services/client_repository.dart';
import 'client_page_helpers.dart';

class EditFitnessRegimePage extends StatefulWidget {
  final String clientId;

  const EditFitnessRegimePage({super.key, required this.clientId});

  @override
  State<EditFitnessRegimePage> createState() => _EditFitnessRegimePageState();
}

class _EditFitnessRegimePageState extends State<EditFitnessRegimePage> {
  final _formKey = GlobalKey<FormState>();
  final _programController = TextEditingController();
  final _scheduleController = TextEditingController();
  final _regimeController = TextEditingController();
  final _cardioController = TextEditingController();
  Client? _client;

  void _loadClient() {
    _client = ClientRepository.instance.getById(widget.clientId);
    if (_client != null) {
      _programController.text = _client!.trainingProgram;
      _scheduleController.text = _client!.schedule;
      _regimeController.text = _client!.fitnessRegime;
      _cardioController.text = _client!.cardioPlan;
    }
  }

  void _saveRegime() {
    if (!_formKey.currentState!.validate() || _client == null) return;

    final updated = _client!.copyWith(
      trainingProgram: _programController.text.trim(),
      schedule: _scheduleController.text.trim(),
      fitnessRegime: _regimeController.text.trim(),
      cardioPlan: _cardioController.text.trim(),
    );

    ClientRepository.instance.updateClient(updated);
    Navigator.pop(context, true);
  }

  @override
  void initState() {
    super.initState();
    _loadClient();
  }

  @override
  void dispose() {
    _programController.dispose();
    _scheduleController.dispose();
    _regimeController.dispose();
    _cardioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_client == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Fitness Regime')),
        body: const Center(child: Text('Client not found.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Fitness Regime')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _programController,
              decoration: const InputDecoration(
                labelText: 'Program name',
                prefixIcon: Icon(Icons.assignment_outlined),
              ),
              validator: (value) => requiredField(value, 'Enter a program'),
            ),
            clientFieldGap,
            TextFormField(
              controller: _scheduleController,
              decoration: const InputDecoration(
                labelText: 'Training schedule',
                hintText: 'Mon / Wed / Fri',
                prefixIcon: Icon(Icons.event_available_outlined),
              ),
              validator: (value) => requiredField(value, 'Enter a schedule'),
            ),
            clientFieldGap,
            TextFormField(
              controller: _regimeController,
              decoration: const InputDecoration(
                labelText: 'Strength / workout regime',
                alignLabelWithHint: true,
              ),
              minLines: 4,
              maxLines: 6,
              validator: (value) => requiredField(value, 'Enter a regime'),
            ),
            clientFieldGap,
            TextFormField(
              controller: _cardioController,
              decoration: const InputDecoration(
                labelText: 'Cardio / conditioning plan',
                alignLabelWithHint: true,
              ),
              minLines: 3,
              maxLines: 5,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveRegime,
              child: const Text('Save Regime'),
            ),
          ],
        ),
      ),
    );
  }
}
