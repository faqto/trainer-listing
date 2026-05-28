import 'package:flutter/material.dart';

class ChooseCoachButton extends StatelessWidget {
  final bool isSaving;
  final bool hasCoaches;
  final bool isUpdating;
  final VoidCallback onPressed;

  const ChooseCoachButton({
    super.key,
    required this.isSaving,
    required this.hasCoaches,
    required this.isUpdating,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isSaving || !hasCoaches ? null : onPressed,
        icon: isSaving
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.check_circle_outline),
        label: Text(isUpdating ? 'Update Details' : 'Choose Coach'),
      ),
    );
  }
}
