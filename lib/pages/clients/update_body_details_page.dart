import 'package:flutter/material.dart';

import '../../models/client_model.dart';
import '../../services/client_repository.dart';

class UpdateBodyDetailsPage extends StatefulWidget {
  final String clientId;

  const UpdateBodyDetailsPage({super.key, required this.clientId});

  @override
  State<UpdateBodyDetailsPage> createState() => _UpdateBodyDetailsPageState();
}

class _UpdateBodyDetailsPageState extends State<UpdateBodyDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _bodyFatController = TextEditingController();
  final _waistController = TextEditingController();
  final _hipsController = TextEditingController();
  final _chestController = TextEditingController();
  Client? _client;

  void _loadClient() {
    _client = ClientRepository.instance.getById(widget.clientId);
    if (_client != null) {
      _weightController.text = _client!.weightKg.toString();
      _heightController.text = _client!.heightCm.toString();
      _bodyFatController.text = _client!.bodyFatPercent.toString();
      _waistController.text = _client!.waistCm.toString();
      _hipsController.text = _client!.hipsCm.toString();
      _chestController.text = _client!.chestCm.toString();
    }
  }

  double _parseDouble(String value) {
    return double.tryParse(value.replaceAll(',', '.')) ?? 0;
  }

  void _saveMetrics() {
    if (!_formKey.currentState!.validate() || _client == null) return;

    final updated = _client!.copyWith(
      weightKg: _parseDouble(_weightController.text),
      heightCm: _parseDouble(_heightController.text),
      bodyFatPercent: _parseDouble(_bodyFatController.text),
      waistCm: _parseDouble(_waistController.text),
      hipsCm: _parseDouble(_hipsController.text),
      chestCm: _parseDouble(_chestController.text),
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
    _weightController.dispose();
    _heightController.dispose();
    _bodyFatController.dispose();
    _waistController.dispose();
    _hipsController.dispose();
    _chestController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_client == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Body Details')),
        body: const Center(child: Text('Client not found.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Update Body Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(labelText: 'Weight (kg)'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty ? 'Enter weight' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _heightController,
                decoration: const InputDecoration(labelText: 'Height (cm)'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty ? 'Enter height' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bodyFatController,
                decoration: const InputDecoration(labelText: 'Body fat %'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _waistController,
                decoration: const InputDecoration(labelText: 'Waist (cm)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _hipsController,
                decoration: const InputDecoration(labelText: 'Hips (cm)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _chestController,
                decoration: const InputDecoration(labelText: 'Chest (cm)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveMetrics,
                child: const Text('Save Metrics'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
