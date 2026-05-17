import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:FitEd/widgets/client/add%20client%20page/add_client_basic_info_section.dart';
import 'package:FitEd/widgets/client/add%20client%20page/add_client_training_info_section.dart';

import '../../helpers/firebase_error_messages.dart';
import '../../models/client_model.dart';
import '../../services/client_repository.dart';

import '../../helpers/client_page_helpers.dart';
import '../../widgets/confirmation_dialog/confirmation_dialog.dart';

class AddClientPage extends StatefulWidget {
  const AddClientPage({super.key});

  @override
  State<AddClientPage> createState() => _AddClientPageState();
}

class _AddClientPageState extends State<AddClientPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _sexController = TextEditingController();
  final _goalController = TextEditingController();

  String? _selectedGoal;
  final List<String> _selectedDays = [];
  TimeOfDay? _scheduleTime;
  String? _scheduleError;
  int _durationHours = 0;
  int _durationMinutes = 0;
  bool _isSaving = false;

  static final List<String> goalOptions = [
    'Weight gain',
    'Weight loss',
    'Muscle gain',
    'Muscle loss',
    otherGoalOption,
  ];

  // Age validation
  String? _validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter age';
    }

    final age = int.tryParse(value);
    if (age == null) {
      return 'Please enter a valid number';
    }

    if (age < 0) {
      return 'Age cannot be negative';
    }

    if (age < 16) {
      return 'Client is too young (minimum 16 years)';
    }

    if (age > 75) {
      return 'Client is too old (maximum 75 years)';
    }

    return null;
  }

  Future<void> _saveClient() async {
    if (_isSaving) return;

    // Validate form
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fix the errors above.')),
      );
      return;
    }

    if (_selectedGoal == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a goal.')));
      return;
    }

    if (_selectedDays.isNotEmpty && _scheduleTime == null) {
      setState(() {
        _scheduleError = 'Please select a time for the schedule';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a schedule time.')),
      );
      return;
    }

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

    if (!await ConfirmationDialog.show(
      context: context,
      title: 'Add Client',
      content: 'Add new client?',
      confirmText: 'Add Client',
    )) {
      return;
    }

    final client = Client(
      id: ClientRepository.instance.createClientId(),
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      age: int.parse(_ageController.text), // Safe now due to validation
      sex: _sexController.text.trim().isEmpty
          ? 'Other'
          : _sexController.text.trim(),
      goal: goal,
      schedule: schedule,
      notes: '',
    );

    setState(() {
      _isSaving = true;
    });

    try {
      await ClientRepository.instance.addClient(client);
      if (mounted) {
        Navigator.pop(context, true);
      }
    } on FirebaseException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(clientSaveErrorMessage(error))));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to save client: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _sexController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: clientPageBackgroundColor,
      appBar: AppBar(
        backgroundColor: clientPageAppBarColor,
        title: const Text('New Client'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AddClientBasicInfoSection(
                nameController: _nameController,
                ageController: _ageController,
                sexController: _sexController,
                emailController: _emailController,
                phoneController: _phoneController,
                onAgeValidator: _validateAge, // Add this callback
              ),
              const SizedBox(height: 16),
              AddClientTrainingInfoSection(
                goalOptions: goalOptions,
                selectedGoal: _selectedGoal,
                goalController: _goalController,
                selectedDays: _selectedDays,
                scheduleTime: _scheduleTime,
                scheduleError: _scheduleError,
                durationHours: _durationHours,
                durationMinutes: _durationMinutes,
                onGoalChanged: (value) => setState(() => _selectedGoal = value),
                onDaysChanged: (days) => setState(() {
                  _selectedDays
                    ..clear()
                    ..addAll(days);
                }),
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
                onPressed: _isSaving ? null : _saveClient,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8C42),
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Save', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
