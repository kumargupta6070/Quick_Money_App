class Validators {
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Mobile number is required';
    }
    final cleaned = value.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length < 10) {
      return 'Please enter a valid 10-digit mobile number';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validateUpi(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'UPI ID is required';
    }
    if (!value.contains('@')) {
      return 'Invalid UPI ID format (e.g. mobile@ybl)';
    }
    return null;
  }

  static String? validateInviteCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Invite code is required';
    }
    return null;
  }
}

