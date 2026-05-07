import 'package:flutter/material.dart';

const clientPageBackgroundColor = Color(0xFFEFF5FB);
const clientPageAppBarColor = Color(0xFF13294B);
const clientFieldGap = SizedBox(height: 12);
const clientSectionGap = SizedBox(height: 16);

String? requiredField(String? value, String message) {
  return value == null || value.trim().isEmpty ? message : null;
}

double parseMetric(String value) {
  return double.tryParse(value.replaceAll(',', '.')) ?? 0;
}

class ClientSectionCard extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  const ClientSectionCard({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140F172A),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
          BoxShadow(
            color: Color(0x080F172A),
            blurRadius: 44,
            offset: Offset(0, 24),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class ClientSectionTitle extends StatelessWidget {
  final String text;

  const ClientSectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}
