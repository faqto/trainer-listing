import 'package:flutter/material.dart';

import '../client_section_card.dart';
import '../client_section_title.dart';
import '../../helpers/client_page_helpers.dart';

class AddClientBasicInfoSection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController ageController;
  final TextEditingController genderController;
  final TextEditingController emailController;
  final TextEditingController phoneController;

  const AddClientBasicInfoSection({
    super.key,
    required this.nameController,
    required this.ageController,
    required this.genderController,
    required this.emailController,
    required this.phoneController,
  });

  @override
  Widget build(BuildContext context) {
    return ClientSectionCard(
      padding: const EdgeInsets.all(18),
      children: [
        const ClientSectionTitle('Basic Info'),
        const SizedBox(height: 16),
        TextFormField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Full Name'),
          validator: (value) => requiredField(value, 'Enter name'),
        ),
        clientFieldGap,
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Age'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: genderController,
                decoration: const InputDecoration(labelText: 'Gender'),
              ),
            ),
          ],
        ),
        clientFieldGap,
        TextFormField(
          controller: emailController,
          decoration: const InputDecoration(labelText: 'Email'),
          keyboardType: TextInputType.emailAddress,
          validator: (value) => requiredField(value, 'Enter email'),
        ),
        clientFieldGap,
        TextFormField(
          controller: phoneController,
          decoration: const InputDecoration(labelText: 'Phone'),
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }
}
