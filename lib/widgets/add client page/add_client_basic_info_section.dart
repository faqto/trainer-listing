import 'package:flutter/material.dart';

import '../client/client_section_card.dart';
import '../client/client_section_title.dart';
import '../../helpers/client_page_helpers.dart';

class AddClientBasicInfoSection extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController ageController;
  final TextEditingController sexController;
  final TextEditingController emailController;
  final TextEditingController phoneController;

  const AddClientBasicInfoSection({
    super.key,
    required this.nameController,
    required this.ageController,
    required this.sexController,
    required this.emailController,
    required this.phoneController,
  });

  @override
  State<AddClientBasicInfoSection> createState() =>
      _AddClientBasicInfoSectionState();
}

class _AddClientBasicInfoSectionState extends State<AddClientBasicInfoSection> {
  String? _selectedSex;

  @override
  void initState() {
    super.initState();
    _selectedSex = widget.sexController.text.isNotEmpty
        ? widget.sexController.text
        : null;
  }

  @override
  Widget build(BuildContext context) {
    return ClientSectionCard(
      padding: const EdgeInsets.all(18),
      children: [
        const ClientSectionTitle('Basic Info'),
        const SizedBox(height: 16),
        TextFormField(
          controller: widget.nameController,
          decoration: const InputDecoration(labelText: 'Full Name'),
          validator: (value) => requiredField(value, 'Enter name'),
        ),
        clientFieldGap,
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: widget.ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Age'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedSex,
                decoration: const InputDecoration(labelText: 'Sex'),
                items: const [
                  DropdownMenuItem(value: 'Male', child: Text('Male')),
                  DropdownMenuItem(value: 'Female', child: Text('Female')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedSex = value;
                    widget.sexController.text = value ?? '';
                  });
                },
                validator: (value) =>
                    value == null || value.isEmpty ? 'Select sex' : null,
              ),
            ),
          ],
        ),
        clientFieldGap,
        TextFormField(
          controller: widget.emailController,
          decoration: const InputDecoration(labelText: 'Email'),
          keyboardType: TextInputType.emailAddress,
          validator: (value) => requiredField(value, 'Enter email'),
        ),
        clientFieldGap,
        TextFormField(
          controller: widget.phoneController,
          decoration: const InputDecoration(labelText: 'Phone'),
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }
}
