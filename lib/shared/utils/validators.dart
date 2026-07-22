String? validateRequired(String? value, {String fieldName = 'This field'}) {
  if (value == null || value.trim().isEmpty) {
    return '$fieldName is required.';
  }
  return null;
}

String? validateEmail(String? value) {
  final requiredMessage = validateRequired(value, fieldName: 'Email');
  if (requiredMessage != null) return requiredMessage;

  final email = value!.trim();
  final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  if (!emailPattern.hasMatch(email)) {
    return 'Enter a valid email address.';
  }
  return null;
}

String? validatePasswordConfirmation({
  required String password,
  required String confirmation,
}) {
  if (password != confirmation) {
    return 'Passwords do not match.';
  }
  return null;
}
