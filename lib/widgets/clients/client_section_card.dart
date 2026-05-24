import 'package:flutter/material.dart';

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
