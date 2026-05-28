import 'package:flutter/material.dart';
import '../../../routes/app_routes.dart';
import '../../../helpers/navigation_helper.dart';

class ActionButtons extends StatelessWidget {
  final String clientId;
  final Future<void> Function() onRefresh;
  const ActionButtons({
    super.key,
    required this.clientId,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => NavigationHelper.navigateAndRefresh(
            context: context,
            routeName: AppRoutes.editClient,
            onRefresh: onRefresh,
            arguments: clientId,
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF13294B),
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text('Edit Client'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => NavigationHelper.navigateAndRefresh(
            context: context,
            routeName: AppRoutes.bodyDetails,
            onRefresh: onRefresh,
            arguments: clientId,
          ),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text('Update Body Metrics'),
        ),
      ],
    );
  }
}
