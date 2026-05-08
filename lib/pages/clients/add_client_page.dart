import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../models/client_model.dart';
import '../../services/client_repository.dart';
import 'client_page_helpers.dart';

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
  final _genderController = TextEditingController();
  final _goalController = TextEditingController();

  String? _selectedGoal;
  final List<String> _selectedDays = [];
  TimeOfDay? _scheduleTime;
  String? _scheduleError;
  bool _isSaving = false;

  static const List<String> goalOptions = [
    'Weight gain',
    'Weight loss',
    'Muscle gain',
    'Muscle loss',
    'Others - please specify',
  ];

  Future<void> _saveClient() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate() || _selectedGoal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete the required fields.')),
      );
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

    final goal = _selectedGoal == 'Others - please specify'
        ? 'Others: ${_goalController.text.trim()}'
        : _selectedGoal!;

    final schedule = formatScheduleDays(_selectedDays, _scheduleTime, context);

    final client = Client(
      id: ClientRepository.instance.createClientId(),
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      age: int.tryParse(_ageController.text) ?? 0,
      gender: _genderController.text.trim().isEmpty
          ? 'Other'
          : _genderController.text.trim(),
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
      ).showSnackBar(SnackBar(content: Text(_firebaseSaveErrorMessage(error))));
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

  String _firebaseSaveErrorMessage(FirebaseException error) {
    switch (error.code) {
      case 'permission-denied':
        return 'Firestore blocked this save. Check your database rules.';
      case 'unavailable':
        return 'Firestore is unavailable right now. Check your connection.';
      case 'not-found':
        return 'Firestore database was not found for this Firebase project.';
      default:
        return error.message ?? 'Unable to save client. Please try again.';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _genderController.dispose();
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
              ClientSectionCard(
                padding: const EdgeInsets.all(18),
                children: [
                  const ClientSectionTitle('Basic Info'),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Full Name'),
                    validator: (value) => requiredField(value, 'Enter name'),
                  ),
                  clientFieldGap,
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _ageController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Age'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _genderController,
                          decoration: const InputDecoration(
                            labelText: 'Gender',
                          ),
                        ),
                      ),
                    ],
                  ),
                  clientFieldGap,
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => requiredField(value, 'Enter email'),
                  ),
                  clientFieldGap,
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Phone'),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 24),
                  const ClientSectionTitle('Training Info'),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedGoal,
                    items: goalOptions.map((goal) {
                      return DropdownMenuItem(value: goal, child: Text(goal));
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedGoal = value),
                    decoration: const InputDecoration(
                      labelText: 'Training Goal',
                    ),
                    validator: (value) =>
                        value == null ? 'Select a goal' : null,
                  ),
                  clientFieldGap,
                  if (_selectedGoal == 'Others - please specify')
                    Column(
                      children: [
                        TextFormField(
                          controller: _goalController,
                          decoration: const InputDecoration(
                            labelText: 'Specify your goal',
                          ),
                          validator: (value) =>
                              requiredField(value, 'Please specify your goal'),
                        ),
                        clientFieldGap,
                      ],
                    ),
                  const Text(
                    'Schedule Days',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                        .map((day) {
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
                        })
                        .toList(),
                  ),
                  if (_selectedDays.isNotEmpty) ...[
                    clientFieldGap,
                    GestureDetector(
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: _scheduleTime ?? TimeOfDay.now(),
                        );
                        if (picked != null && mounted) {
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
                        child: Text(
                          _scheduleTime?.format(context) ?? 'Select time',
                        ),
                      ),
                    ),
                  ],
                ],
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
