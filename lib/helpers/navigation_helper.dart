import 'package:flutter/material.dart';

class NavigationHelper {
  /// Pushes [routeName] and calls [onRefresh] when the page pops with `true`.
  static Future<void> navigateAndRefresh({
    required BuildContext context,
    required String routeName,
    required Future<void> Function() onRefresh,
    Object? arguments,
  }) async {
    final result = await Navigator.pushNamed(
      context,
      routeName,
      arguments: arguments,
    );
    if (result == true) {
      await onRefresh();
    }
  }
}
