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
  final _scheduleController = TextEditingController();
  
  String? _selectedGoal;
  String? _scheduleDate;
  String? _scheduleTime;
  
  static const List<String> goalOptions = [
    'Weight gain',
    'Weight loss',
    'Muscle gain',
    'Muscle loss',
    'Others - please specify'
  ];

  void _saveClient() {
    if (!_formKey.currentState!.validate() || _selectedGoal == null) return;

    final goal = _selectedGoal == 'Others - please specify'
        ? 'Others: ${_goalController.text.trim()}'
        : _selectedGoal!;

    final schedule = _scheduleDate != null && _scheduleTime != null
        ? '$_scheduleDate at $_scheduleTime'
        : '';

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
    _scheduleController.dispose();
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
                    value: _selectedGoal,
                    items: goalOptions.map((goal) {
                      return DropdownMenuItem(value: goal, child: Text(goal));
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedGoal = value),
                    decoration: const InputDecoration(labelText: 'Training Goal'),
                    validator: (value) => value == null ? 'Select a goal' : null,
                  ),
                  clientFieldGap,
                  if (_selectedGoal == 'Others - please specify')
                    Column(
                      children: [
                        TextFormField(
                          controller: _goalController,
                          decoration: const InputDecoration(labelText: 'Specify your goal'),
                          validator: (value) => requiredField(value, 'Please specify your goal'),
                        ),
                        clientFieldGap,
                      ],
                    ),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() {
                          _scheduleDate = '${picked.month}/${picked.day}/${picked.year}';
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Schedule Date',
                        suffixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(_scheduleDate ?? 'Select date'),
                    ),
                  ),
                  clientFieldGap,
                  GestureDetector(
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          _scheduleTime = picked.format(context);
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
                      child: Text(_scheduleTime ?? 'Select time'),
                    ),
                  ),
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
