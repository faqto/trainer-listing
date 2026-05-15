import 'package:flutter/material.dart';

mixin EditPageMixin<T extends StatefulWidget> on State<T> {
  bool _isSaving = false;

  Future<void> executeWithLoading(Future<void> Function() action) async {
    if (_isSaving) return;

    setState(() => _isSaving = true);
    try {
      await action();
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  bool get isSaving => _isSaving;
}
