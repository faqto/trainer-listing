import 'package:flutter/material.dart';

class PageSaveButton extends StatelessWidget {
  final bool isSaving;
  final VoidCallback onSave;
  final String label;
  final Color? backgroundColor;

  const PageSaveButton({
    super.key,
    required this.isSaving,
    required this.onSave,
    this.label = 'Save',
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isSaving ? null : onSave,
      style: backgroundColor != null
          ? ElevatedButton.styleFrom(backgroundColor: backgroundColor)
          : null,
      child: isSaving
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(label),
    );
  }
}
