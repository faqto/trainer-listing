import 'package:flutter/material.dart';

class RegisterPasswordHint extends StatelessWidget {
  const RegisterPasswordHint({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.info_outline_rounded, size: 13, color: Color(0xFF94A3B8)),
        SizedBox(width: 5),
        Text(
          'Must be at least 6 characters',
          style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
        ),
      ],
    );
  }
}
