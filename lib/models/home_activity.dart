import 'package:flutter/material.dart';

import 'activity_event.dart';

class HomeActivity {
  final String name;
  final String subtitle;
  final String time;
  final IconData icon;
  final Color color;
  final ActivityEvent? event;

  HomeActivity({
    required this.name,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.color,
    this.event,
  });
}
