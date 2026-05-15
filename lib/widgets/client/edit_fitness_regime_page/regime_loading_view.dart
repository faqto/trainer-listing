import 'package:flutter/material.dart';

class RegimeLoadingView extends StatelessWidget {
  const RegimeLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Fitness Regime')),
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}
