import 'package:flutter/material.dart';
import 'package:trainer_listing/widgets/client/edit%20client%20page/edit_client_form_fields.dart';
import '../../models/client_model.dart';
import '../../services/client_repository.dart';
import '../../helpers/client_page_helpers.dart';
import '../../helpers/edit_page_mixin.dart';
import '../../widgets/loading_overlay.dart';

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

      if (_client != null) {
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
    } catch (e) {
      debugPrint(e.toString());
      _errorMessage = 'Failed to load client data.';
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveClient() async {
    if (!_formKey.currentState!.validate() ||
        _client == null ||
        _selectedGoal == null) {
      return;
    }

    if (_selectedDays.isNotEmpty && _scheduleTime == null) {
      setState(() {
        _scheduleError = 'Please select a time for the schedule';
      });
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

      if (mounted) {
        Navigator.pop(context, true);
      }
    });
  }

  Future<void> _deleteClient() async {
    if (_client == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Delete Client'),
          content: Text('Delete ${_client!.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final clientId = _client!.id;

    try {
      await executeWithLoading(() async {
        await ClientRepository.instance.deleteClient(clientId);

        if (mounted) {
          Navigator.of(context).pop(true);
        }
      });
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
    }
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
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Edit Client')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_client == null || _errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Client')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                _errorMessage ?? 'Client not found.',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadClient,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
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
                ElevatedButton(
                  onPressed: isSaving ? null : _saveClient,
                  child: isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save Changes'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
