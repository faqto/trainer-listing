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
  final _regimeController = TextEditingController();
  final _cardioController = TextEditingController();
  Client? _client;

  List<String> _selectedDays = [];
  TimeOfDay? _scheduleTime;
  String? _scheduleError;

  void _loadClient() {
    _client = ClientRepository.instance.getById(widget.clientId);
    if (_client != null) {
      _selectedDays = parseScheduleDays(_client!.schedule);
      _scheduleTime = parseScheduleTime(_client!.schedule);
      _regimeController.text = _client!.fitnessRegime;
      _cardioController.text = _client!.cardioPlan;
    }
  }

  void _saveRegime() {
    if (!_formKey.currentState!.validate() || _client == null) return;

    if (_selectedDays.isNotEmpty && _scheduleTime == null) {
      setState(() {
        _scheduleError = 'Please select a time for the schedule';
      });
      return;
    }

    final schedule = formatScheduleDays(_selectedDays, _scheduleTime, context);

    final updated = _client!.copyWith(
      schedule: schedule,
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
            const Text('Schedule Days', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map((day) {
                return FilterChip(
                  label: Text(day),
                  selected: _selectedDays.contains(day),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedDays.add(day);
                      } else {
                        _selectedDays.remove(day);
                        if (_selectedDays.isEmpty) {
                          _scheduleTime = null;
                          _scheduleError = null;
                        }
                      }
                    });
                  },
                );
              }).toList(),
            ),
            if (_selectedDays.isNotEmpty) ...[
              clientFieldGap,
              GestureDetector(
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: _scheduleTime ?? TimeOfDay.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      _scheduleTime = picked;
                      _scheduleError = null;
                    });
                  }
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Schedule Time',
                    suffixIcon: const Icon(Icons.access_time),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    errorText: _scheduleError,
                  ),
                  child: Text(_scheduleTime?.format(context) ?? 'Select time'),
                ),
              ),
            ],
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
