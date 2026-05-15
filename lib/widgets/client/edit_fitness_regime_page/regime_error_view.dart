import 'package:flutter/material.dart';

class RegimeErrorView extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback onRetry;

  const RegimeErrorView({super.key, this.errorMessage, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Fitness Regime')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              errorMessage ?? 'Client not found.',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
