import 'package:flutter/material.dart';

import '../../pages/home/home_constants.dart';

class MetricDivider extends StatelessWidget {
  const MetricDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: cardBorderColor,
    );
  }
}
