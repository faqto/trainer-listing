import 'package:flutter/material.dart';

import '../../models/client_model.dart';
import '../../services/client_repository.dart';

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
  final _programController = TextEditingController();
  final _scheduleController = TextEditingController();

  void _saveClient() {
    if (!_formKey.currentState!.validate()) return;

    final client = Client(
      id: ClientRepository.instance.createClientId(),
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      age: int.tryParse(_ageController.text) ?? 0,
      gender: _genderController.text.trim().isEmpty ? 'Other' : _genderController.text.trim(),
      goal: _goalController.text.trim(),
      trainingProgram: _programController.text.trim(),
      schedule: _scheduleController.text.trim(),
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
    _programController.dispose();
    _scheduleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF5FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF13294B),
        title: const Text('New Client'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Basic Info', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Full Name'),
                    validator: (value) => value == null || value.isEmpty ? 'Enter name' : null,
                  ),
                  const SizedBox(height: 12),
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
                          decoration: const InputDecoration(labelText: 'Gender'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => value == null || value.isEmpty ? 'Enter email' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Phone'),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 24),
                  const Text('Training Info', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _goalController,
                    decoration: const InputDecoration(labelText: 'Goal'),
                    validator: (value) => value == null || value.isEmpty ? 'Enter goal' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _programController,
                    decoration: const InputDecoration(labelText: 'Program'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _scheduleController,
                    decoration: const InputDecoration(labelText: 'Training schedule'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveClient,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8C42),
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Save', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
