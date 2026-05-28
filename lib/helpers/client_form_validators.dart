String? validateRequired(String? value, String message) {
  return value == null || value.trim().isEmpty ? message : null;
}

String? validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return 'Please enter your email';
  if (!email.contains('@')) return 'Enter a valid email';
  return null;
}

String? validateAge(String? value) {
  final age = int.tryParse(value?.trim() ?? '');
  if (age == null) return 'Please enter your age';
  if (age < 16) return 'Minimum age is 16';
  if (age > 75) return 'Maximum age is 75';
  return null;
}

String? validateMetric(
  String? value,
  String label, {
  bool required = false,
  double? max,
}) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) {
    return required ? 'Please enter your $label' : null;
  }
  final metric = double.tryParse(text.replaceAll(',', '.'));
  if (metric == null) return 'Enter a valid $label';
  if (metric <= 0) return '$label must be greater than zero';
  if (max != null && metric > max) return '$label looks too high';
  return null;
}
