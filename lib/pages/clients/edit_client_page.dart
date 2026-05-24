import 'package:flutter/material.dart';
import 'package:fit_ed/widgets/shared/page_error_view.dart';
import 'package:fit_ed/widgets/shared/page_loading_view.dart';
import 'package:fit_ed/widgets/shared/page_save_button.dart';
import 'package:fit_ed/widgets/clients/edit_client_page/edit_client_form_fields.dart';
import '../../models/client_model.dart';
import '../../services/client_repository.dart';
import '../../helpers/client_page_helpers.dart';
import '../../helpers/edit_page_mixin.dart';
import '../../widgets/shared/loading_overlay.dart';
import '../../widgets/confirmation_dialog/confirmation_dialog.dart';

class EditClientPage extends StatefulWidget {
  final String clientId;
  const EditClientPage({super.key, required this.clientId});

  @override
  State<EditClientPage> createState() => _EditClientPageState();
}

class _EditClientPageState extends State<EditClientPage> with EditPageMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _goalController = TextEditingController();
  final _notesController = TextEditingController();

  Client? _client;
  bool _isLoading = true;
  String? _errorMessage;

  String? _selectedGoal;
  List<String> _selectedDays = [];
  TimeOfDay? _scheduleTime;
  String? _scheduleError;
  int _durationHours = 0;
  int _durationMinutes = 0;

  static final List<String> goalOptions = [
    'Weight gain',
    'Weight loss',
    'Muscle gain',
    'Muscle loss',
    otherGoalOption,
  ];

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
      if (_client != null) _populateFormData();
    } catch (e) {
      debugPrint(e.toString());
      _errorMessage = 'Failed to load client data.';
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _populateFormData() {
    if (_client == null) return;

    _nameController.text = _client!.name;
    _emailController.text = _client!.email;
    _phoneController.text = _client!.phone;
    _notesController.text = _client!.notes;

    if (_client!.goal.startsWith('Others:')) {
      _selectedGoal = otherGoalOption;
      _goalController.text = _client!.goal.replaceFirst('Others: ', '');
    } else {
      _selectedGoal = goalOptions.contains(_client!.goal)
          ? _client!.goal
          : otherGoalOption;
      if (_selectedGoal == otherGoalOption) {
        _goalController.text = _client!.goal;
      }
    }

    _selectedDays = parseScheduleDays(_client!.schedule);
    _scheduleTime = parseScheduleTime(_client!.schedule);
    final totalMin = parseScheduleDurationMinutes(_client!.schedule);
    _durationHours = totalMin ~/ 60;
    _durationMinutes = totalMin % 60;
  }

  Future<void> _saveClient() async {
    if (!_formKey.currentState!.validate() ||
        _client == null ||
        _selectedGoal == null) {
      return;
    }

    if (_selectedDays.isNotEmpty && _scheduleTime == null) {
      setState(() => _scheduleError = 'Please select a time for the schedule');
      return;
    }

    await executeWithLoading(() async {
      final goal = _selectedGoal == otherGoalOption
          ? 'Others: ${_goalController.text.trim()}'
          : _selectedGoal!;

      final schedule = formatScheduleDays(
        _selectedDays,
        _scheduleTime,
        context,
        durationHours: _durationHours,
        durationMinutes: _durationMinutes,
      );

      final updated = _client!.copyWith(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        goal: goal,
        schedule: schedule,
        notes: _notesController.text.trim(),
      );

      await ClientRepository.instance.updateClient(updated);
      if (mounted) Navigator.pop(context, true);
    });
  }

  Future<void> _deleteClient() async {
    if (_client == null) return;

    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Delete Client',
      content:
          'Are you sure you want to delete ${_client!.name}? This action cannot be undone.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      isDangerous: true,
    );

    if (!confirmed) return;

    final clientId = _client!.id;
    final clientName = _client!.name;

    await executeWithLoading(() async {
      try {
        await ClientRepository.instance.deleteClient(clientId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$clientName has been deleted'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        debugPrint('Error deleting client: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete client: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
        rethrow;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _goalController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use shared loading view
    if (_isLoading) {
      return const PageLoadingView(title: 'Edit Client');
    }

    // Use shared error view
    if (_client == null || _errorMessage != null) {
      return PageErrorView(
        title: 'Edit Client',
        errorMessage: _errorMessage ?? 'Client not found.',
        onRetry: _loadClient,
        showBackButton: true,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Client'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: isSaving ? null : _deleteClient,
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: isSaving,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // Your existing form fields widget
                EditClientFormFields(
                  nameController: _nameController,
                  emailController: _emailController,
                  phoneController: _phoneController,
                  goalController: _goalController,
                  notesController: _notesController,
                  goalOptions: goalOptions,
                  selectedGoal: _selectedGoal,
                  selectedDays: _selectedDays,
                  scheduleTime: _scheduleTime,
                  scheduleError: _scheduleError,
                  durationHours: _durationHours,
                  durationMinutes: _durationMinutes,
                  onGoalChanged: (value) =>
                      setState(() => _selectedGoal = value),
                  onDaysChanged: (days) => setState(() => _selectedDays = days),
                  onTimeChanged: (time) => setState(() => _scheduleTime = time),
                  onErrorChanged: (error) =>
                      setState(() => _scheduleError = error),
                  onDurationHoursChanged: (h) =>
                      setState(() => _durationHours = h),
                  onDurationMinutesChanged: (m) =>
                      setState(() => _durationMinutes = m),
                ),
                const SizedBox(height: 24),
                // Use shared save button
                PageSaveButton(
                  isSaving: isSaving,
                  onSave: _saveClient,
                  label: 'Save Changes',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
