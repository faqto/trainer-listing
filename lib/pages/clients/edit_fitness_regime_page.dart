import 'package:flutter/material.dart';
import 'package:trainer_listing/helpers/client_page_helpers.dart';
import 'package:trainer_listing/models/activity_event.dart';
import 'package:trainer_listing/widgets/client/edit_fitness_regime_page/regime_error_view.dart';
import 'package:trainer_listing/widgets/client/edit_fitness_regime_page/regime_form_fields.dart';
import 'package:trainer_listing/widgets/client/edit_fitness_regime_page/regime_loading_view.dart';
import 'package:trainer_listing/widgets/confirmation_dialog/confirmation_dialog.dart';
import '../../models/client_model.dart';
import '../../services/client_repository.dart';
import '../../services/activity_repository.dart';
import '../../helpers/edit_page_mixin.dart';
import '../../widgets/loading_overlay.dart';

class EditFitnessRegimePage extends StatefulWidget {
  final String clientId;
  const EditFitnessRegimePage({super.key, required this.clientId});

  @override
  State<EditFitnessRegimePage> createState() => _EditFitnessRegimePageState();
}

class _EditFitnessRegimePageState extends State<EditFitnessRegimePage>
    with EditPageMixin {
  final _formKey = GlobalKey<FormState>();
  final _regimeController = TextEditingController();
  final _cardioController = TextEditingController();

  Client? _client;
  bool _isLoading = true;
  String? _errorMessage;

  // Schedule data
  List<String> _selectedDays = [];
  TimeOfDay? _scheduleTime;
  String? _scheduleError;
  int _durationHours = 0;
  int _durationMinutes = 0;

  @override
  void initState() {
    super.initState();
    _loadClient();
  }

  Future<void> _loadClient() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      _client = await ClientRepository.instance.getById(widget.clientId);
      if (!mounted) return;
      _populateFormData();
    } catch (e) {
      debugPrint(e.toString());
      _errorMessage = 'Failed to load client data.';
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _populateFormData() {
    if (_client == null) return;

    _selectedDays = parseScheduleDays(_client!.schedule);
    _scheduleTime = parseScheduleTime(_client!.schedule);
    _regimeController.text = _client!.fitnessRegime;
    _cardioController.text = _client!.cardioPlan;

    final totalMin = parseScheduleDurationMinutes(_client!.schedule);
    _durationHours = totalMin ~/ 60;
    _durationMinutes = totalMin % 60;
  }

  Future<void> _saveRegime() async {
    if (!_validateForm()) return;
    if (!await _confirmSave()) return;

    await executeWithLoading(() async {
      await _updateClient();
      await _logActivity();
      if (mounted) Navigator.pop(context, true);
    });
  }

  bool _validateForm() {
    if (!_formKey.currentState!.validate() || _client == null) return false;

    if (_selectedDays.isNotEmpty && _scheduleTime == null) {
      setState(() => _scheduleError = 'Please select a time for the schedule');
      return false;
    }
    return true;
  }

  Future<bool> _confirmSave() async {
    return await ConfirmationDialog.show(
      context: context,
      title: 'Save Regime',
      content: 'Update fitness regime?',
      confirmText: 'Save Regime',
    );
  }

  Future<void> _updateClient() async {
    final schedule = formatScheduleDays(
      _selectedDays,
      _scheduleTime,
      context,
      durationHours: _durationHours,
      durationMinutes: _durationMinutes,
    );

    final updated = _client!.copyWith(
      schedule: schedule,
      fitnessRegime: _regimeController.text.trim(),
      cardioPlan: _cardioController.text.trim(),
    );

    await ClientRepository.instance.updateClient(updated);
  }

  Future<void> _logActivity() async {
    await ActivityRepository.instance.log(
      ActivityEvent(
        id: '',
        type: ActivityType.regimeChanged,
        clientId: _client!.id,
        clientName: _client!.name,
        description:
            'Fitness regime updated — ${_regimeController.text.trim()}',
        timestamp: DateTime.now(),
      ),
    );
  }

  void _updateScheduleState({
    List<String>? days,
    TimeOfDay? time,
    String? error,
    int? hours,
    int? minutes,
  }) {
    setState(() {
      if (days != null) _selectedDays = days;
      if (time != null) _scheduleTime = time;
      if (error != null) _scheduleError = error;
      if (hours != null) _durationHours = hours;
      if (minutes != null) _durationMinutes = minutes;
    });
  }

  @override
  void dispose() {
    _regimeController.dispose();
    _cardioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const RegimeLoadingView();
    if (_client == null || _errorMessage != null) {
      return RegimeErrorView(errorMessage: _errorMessage, onRetry: _loadClient);
    }

    return Scaffold(
      appBar: AppBar(title: Text('Fitness Regime')),
      body: LoadingOverlay(
        isLoading: isSaving,
        child: Form(
          key: _formKey,
          child: RegimeFormFields(
            selectedDays: _selectedDays,
            scheduleTime: _scheduleTime,
            scheduleError: _scheduleError,
            durationHours: _durationHours,
            durationMinutes: _durationMinutes,
            regimeController: _regimeController,
            cardioController: _cardioController,
            isSaving: isSaving,
            onScheduleChanged: _updateScheduleState,
            onSave: _saveRegime,
          ),
        ),
      ),
    );
  }
}
