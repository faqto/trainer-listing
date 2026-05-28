import 'package:fit_ed/helpers/client_form_validators.dart';
import 'package:flutter/material.dart';
import 'section_card.dart';

class ClientDetailsSection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController ageController;
  final TextEditingController goalController;
  final String selectedSex;
  final String? selectedGoal;
  final ValueChanged<String?> onSexChanged;
  final ValueChanged<String?> onGoalChanged;

  static const sexOptions = [
    'Not specified',
    'Female',
    'Male',
    'Nonbinary',
    'Other',
  ];
  static const customGoalOption = 'Customize';
  static const goalOptions = [
    'Weight loss',
    'Weight gain',
    'Muscle gain',
    'Muscle loss',
    customGoalOption,
  ];

  const ClientDetailsSection({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.ageController,
    required this.goalController,
    required this.selectedSex,
    required this.selectedGoal,
    required this.onSexChanged,
    required this.onGoalChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Your Details',
      icon: Icons.assignment_ind_outlined,
      children: [
        TextFormField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Full Name'),
          validator: (value) =>
              validateRequired(value, 'Please enter your name'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: emailController,
          decoration: const InputDecoration(labelText: 'Email'),
          keyboardType: TextInputType.emailAddress,
          validator: validateEmail,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: phoneController,
          decoration: const InputDecoration(labelText: 'Phone'),
          keyboardType: TextInputType.phone,
          validator: (value) =>
              validateRequired(value, 'Please enter your phone number'),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: ageController,
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: validateAge,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: selectedSex,
                decoration: const InputDecoration(labelText: 'Gender'),
                items: sexOptions
                    .map(
                      (sex) => DropdownMenuItem(value: sex, child: Text(sex)),
                    )
                    .toList(),
                onChanged: onSexChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: selectedGoal,
          decoration: const InputDecoration(labelText: 'Fitness Goal'),
          items: goalOptions
              .map((goal) => DropdownMenuItem(value: goal, child: Text(goal)))
              .toList(),
          onChanged: onGoalChanged,
          validator: (value) =>
              value == null ? 'Please select your fitness goal' : null,
        ),
        if (selectedGoal == customGoalOption) ...[
          const SizedBox(height: 12),
          TextFormField(
            controller: goalController,
            decoration: const InputDecoration(labelText: 'Custom Fitness Goal'),
            validator: (value) =>
                validateRequired(value, 'Please enter your fitness goal'),
          ),
        ],
      ],
    );
  }
}
