import 'package:flutter/material.dart';

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
  List<String> _selectedDays = [];
  TimeOfDay? _scheduleTime;

  static const List<String> goalOptions = [
    'Weight gain',
    'Weight loss',
    'Muscle gain',
    'Muscle loss',
    'Others - please specify',
  ];

  void _saveClient() {
    if (!_formKey.currentState!.validate() || _selectedGoal == null) return;

    final goal = _selectedGoal == 'Others - please specify'
        ? 'Others: ${_goalController.text.trim()}'
        : _selectedGoal!;

    final schedule = _selectedDays.isEmpty ? '' : _selectedDays.join(' / ');

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

    ClientRepository.instance.addClient(client);
    Navigator.pop(context, true);
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
                          initialTime: TimeOfDay.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            _scheduleTime = picked;
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
                onPressed: _saveClient,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8C42),
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Save', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
