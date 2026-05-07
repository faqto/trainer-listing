import 'package:flutter/material.dart';

class HomeActivity {
  final String name;
  final String subtitle;
  final String time;
  final IconData icon;
  final Color color;

  HomeActivity({
    required this.name,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.color,
  });
}

extension ColorUtils on Color {
  Color darken([double amount = .2]) {
    final hsl = HSLColor.fromColor(this);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }
}
