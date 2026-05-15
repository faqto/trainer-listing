import 'package:flutter/material.dart';
import 'package:trainer_listing/helpers/edit_page_mixin.dart';
import 'package:trainer_listing/widgets/shared/loading_overlay.dart';
import 'package:trainer_listing/widgets/shared/page_error_view.dart';
import 'package:trainer_listing/widgets/shared/page_loading_view.dart';

abstract class EditPageBase<T extends StatefulWidget> extends State<T>
    with EditPageMixin {
  String get pageTitle;
  Future<void> loadData();
  Widget buildForm(BuildContext context);

  bool _isLoading = true;
  String? _errorMessage;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  @override
  void initState() {
    super.initState();
    refreshData();
  }

  Future<void> refreshData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await loadData();
    } catch (e) {
      debugPrint(e.toString());
      if (mounted) setState(() => _errorMessage = 'Failed to load data.');
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return PageLoadingView(title: pageTitle);
    }

    if (_errorMessage != null) {
      return PageErrorView(
        title: pageTitle,
        errorMessage: _errorMessage,
        onRetry: refreshData,
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(pageTitle)),
      body: LoadingOverlay(isLoading: isSaving, child: buildForm(context)),
    );
  }
}
