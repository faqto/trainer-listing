import 'package:flutter/material.dart';

import '../../models/client_model.dart';
import '../../services/client_repository.dart';
import '../../widgets/client/client_schedule_picker.dart';
import '../../helpers/client_page_helpers.dart';
import '../../widgets/confirmation_dialog/confirmation_dialog.dart';

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

  @override
  void initState() {
    super.initState();
    _loadClient();
  }

  Future<void> _loadClient() async {
    _client = await ClientRepository.instance.getById(widget.clientId);
    if (!mounted) return;
    if (_client != null) {
      _selectedDays = parseScheduleDays(_client!.schedule);
      _scheduleTime = parseScheduleTime(_client!.schedule);
      _regimeController.text = _client!.fitnessRegime;
      _cardioController.text = _client!.cardioPlan;
    }
    setState(() {});
  }

  Future<void> _saveRegime() async {
    if (!_formKey.currentState!.validate() || _client == null) return;

    if (_selectedDays.isNotEmpty && _scheduleTime == null) {
      setState(() {
        _scheduleError = 'Please select a time for the schedule';
      });
      return;
    }

    if (!await ConfirmationDialog.show(
      context: context,
      title: 'Save Regime',
      content: 'Update fitness regime?',
      confirmText: 'Save Regime',
    )) {
      return;
    }

    final schedule = formatScheduleDays(_selectedDays, _scheduleTime, context);

    final updated = _client!.copyWith(
      schedule: schedule,
      fitnessRegime: _regimeController.text.trim(),
      cardioPlan: _cardioController.text.trim(),
    );

    await ClientRepository.instance.updateClient(updated);
    if (mounted) {
      Navigator.pop(context, true);
    }
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
            ClientSchedulePicker(
              selectedDays: _selectedDays,
              selectedTime: _scheduleTime,
              errorText: _scheduleError,
              onDaysChanged: (days) => setState(() => _selectedDays = days),
              onTimeChanged: (time) => setState(() => _scheduleTime = time),
              onErrorChanged: (error) => setState(() => _scheduleError = error),
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
