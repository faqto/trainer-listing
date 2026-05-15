import 'package:flutter/material.dart';
import '../../../widgets/shared/edit_page_base.dart';
import '../../../widgets/shared/schedule_form_section.dart';
import '../../../widgets/shared/page_save_button.dart';
import '../../../helpers/client_page_helpers.dart';
import '../../../models/client_model.dart';
import '../../../services/client_repository.dart';
import '../../../widgets/confirmation_dialog/confirmation_dialog.dart';

class EditFitnessRegimePage extends StatefulWidget {
  final String clientId;
  const EditFitnessRegimePage({super.key, required this.clientId});

  @override
  State<EditFitnessRegimePage> createState() => _EditFitnessRegimePageState();
}

class _EditFitnessRegimePageState extends EditPageBase<EditFitnessRegimePage> {
  @override
  String get pageTitle => 'Fitness Regime';

  final _formKey = GlobalKey<FormState>();
  final _regimeController = TextEditingController();
  final _cardioController = TextEditingController();
  Client? _client;

  // Schedule state
  List<String> _selectedDays = [];
  TimeOfDay? _scheduleTime;
  String? _scheduleError;
  int _durationHours = 0;
  int _durationMinutes = 0;

  @override
  Future<void> loadData() async {
    _client = await ClientRepository.instance.getById(widget.clientId);
    if (_client != null) {
      _selectedDays = parseScheduleDays(_client!.schedule);
      _scheduleTime = parseScheduleTime(_client!.schedule);
      _regimeController.text = _client!.fitnessRegime;
      _cardioController.text = _client!.cardioPlan;
      final totalMin = parseScheduleDurationMinutes(_client!.schedule);
      _durationHours = totalMin ~/ 60;
      _durationMinutes = totalMin % 60;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _client == null) return;
    if (_selectedDays.isNotEmpty && _scheduleTime == null) {
      setState(() => _scheduleError = 'Please select a time');
      return;
    }

    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Save Regime',
      content: 'Update fitness regime?',
      confirmText: 'Save',
    );
    if (!confirmed) return;

    await executeWithLoading(() async {
      final schedule = formatScheduleDays(
        _selectedDays,
        _scheduleTime,
        context,
        durationHours: _durationHours,
        durationMinutes: _durationMinutes,
      );

      await ClientRepository.instance.updateClient(
        _client!.copyWith(
          schedule: schedule,
          fitnessRegime: _regimeController.text.trim(),
          cardioPlan: _cardioController.text.trim(),
        ),
      );

      if (mounted) Navigator.pop(context, true);
    });
  }

  @override
  Widget buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ScheduleFormSection(
            selectedDays: _selectedDays,
            scheduleTime: _scheduleTime,
            errorText: _scheduleError,
            durationHours: _durationHours,
            durationMinutes: _durationMinutes,
            onDaysChanged: (days) => setState(() => _selectedDays = days),
            onTimeChanged: (time) => setState(() => _scheduleTime = time),
            onErrorChanged: (error) => setState(() => _scheduleError = error),
            onHoursChanged: (h) => setState(() => _durationHours = h),
            onMinutesChanged: (m) => setState(() => _durationMinutes = m),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _regimeController,
            decoration: const InputDecoration(labelText: 'Workout regime'),
            minLines: 4,
            maxLines: 6,
            validator: (v) => requiredField(v, 'Enter a regime'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _cardioController,
            decoration: const InputDecoration(labelText: 'Cardio plan'),
            minLines: 3,
            maxLines: 5,
          ),
          const SizedBox(height: 24),
          PageSaveButton(
            isSaving: isSaving,
            onSave: _save,
            label: 'Save Regime',
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _regimeController.dispose();
    _cardioController.dispose();
    super.dispose();
  }
}
