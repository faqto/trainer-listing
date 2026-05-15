import 'package:flutter/material.dart';

class NavigationHelper {
  static Future<void> navigateAndRefresh({
    required BuildContext context,
    required String routeName,
    required VoidCallback onRefresh,
    Object? arguments,
  }) async {
    final result = await Navigator.pushNamed(
      context,
      routeName,
      arguments: arguments,
    );
    if (result == true) {
      onRefresh();
    }
  }

  static Future<void> navigateAndRefreshWithLoading({
    required BuildContext context,
    required String routeName,
    required Future<void> Function() onRefresh,
    Object? arguments,
    bool showLoadingIndicator = false,
  }) async {
    final result = await Navigator.pushNamed(
      context,
      routeName,
      arguments: arguments,
    );
    if (result == true) {
      if (showLoadingIndicator) {
        await _showRefreshWithDialog(context, onRefresh);
      } else {
        await onRefresh();
      }
    }
  }

  static Future<void> _showRefreshWithDialog(
    BuildContext context,
    Future<void> Function() onRefresh,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    await onRefresh();

    if (context.mounted) {
      Navigator.pop(context);
    }
  }
}
