import 'package:flutter/material.dart';

import '../../models/client_model.dart';
import '../../services/client_repository.dart';
import 'client_page_helpers.dart';

class EditClientPage extends StatefulWidget {
  final String clientId;

  const EditClientPage({super.key, required this.clientId});

  @override
  State<EditClientPage> createState() => _EditClientPageState();
}

class _EditClientPageState extends State<EditClientPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _goalController = TextEditingController();
  final _notesController = TextEditingController();
  Client? _client;

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

  void _loadClient() {
    _client = ClientRepository.instance.getById(widget.clientId);
    if (_client != null) {
      _nameController.text = _client!.name;
      _emailController.text = _client!.email;
      _phoneController.text = _client!.phone;
      _notesController.text = _client!.notes;

      if (_client!.goal.startsWith('Others:')) {
        _selectedGoal = 'Others - please specify';
        _goalController.text = _client!.goal.replaceFirst('Others: ', '');
      } else {
        _selectedGoal = goalOptions.contains(_client!.goal)
            ? _client!.goal
            : 'Others - please specify';
        if (_selectedGoal == 'Others - please specify') {
          _goalController.text = _client!.goal;
        }
      }

      _selectedDays = _client!.schedule.split(' at ').first.split(' / ').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
      _scheduleTime = parseScheduleTime(_client!.schedule);
    }
  }

  void _saveClient() {
    if (!_formKey.currentState!.validate() ||
        _client == null ||
        _selectedGoal == null) {
      return;
    }

    final goal = _selectedGoal == 'Others - please specify'
        ? 'Others: ${_goalController.text.trim()}'
        : _selectedGoal!;

    final schedule = _selectedDays.isEmpty ? '' : _selectedDays.join(' / ') + (_scheduleTime != null ? ' at ${_scheduleTime!.format(context)}' : '');

    final updated = _client!.copyWith(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      goal: goal,
      schedule: schedule,
      notes: _notesController.text.trim(),
    );

    ClientRepository.instance.updateClient(updated);
    Navigator.pop(context, true);
  }

  void _deleteClient() {
    if (_client == null) return;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Delete Client'),
          content: Text('Delete ${_client!.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                ClientRepository.instance.deleteClient(_client!.id);
                Navigator.of(ctx).pop();
                Navigator.of(context).pop(true);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _loadClient();
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
    if (_client == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Client')),
        body: const Center(child: Text('Client not found.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Client'),
        actions: [
          IconButton(icon: const Icon(Icons.delete), onPressed: _deleteClient),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) =>
                    requiredField(value, 'Please enter a name'),
              ),
              clientFieldGap,
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    requiredField(value, 'Please enter an email'),
              ),
              clientFieldGap,
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),
              clientFieldGap,
              DropdownButtonFormField<String>(
                initialValue: _selectedGoal,
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
                      initialTime: _scheduleTime ?? TimeOfDay.now(),
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
                    child: Text(_scheduleTime?.format(context) ?? 'Select time'),
                  ),
                ),
              ],
              clientFieldGap,
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveClient,
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
