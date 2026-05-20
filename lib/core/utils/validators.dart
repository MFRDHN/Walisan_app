import '../constants/app_strings.dart';

class Validators {
  Validators._();

  /// Validates that a field is not empty.
  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null
          ? '$fieldName tidak boleh kosong'
          : AppStrings.fieldRequired;
    }
    return null;
  }

  /// Validates email format.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.fieldRequired;
    }
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return AppStrings.emailInvalid;
    }
    return null;
  }

  /// Validates password length (min 8 characters).
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldRequired;
    }
    if (value.length < 8) {
      return AppStrings.passwordTooShort;
    }
    return null;
  }

  /// Validates that confirm password matches original password.
  static String? Function(String?) confirmPassword(String? original) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return AppStrings.fieldRequired;
      }
      if (value != original) {
        return AppStrings.passwordMismatch;
      }
      return null;
    };
  }

  /// Validates Indonesian phone number format.
  static String? phoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.fieldRequired;
    }
    final phoneRegex = RegExp(r'^(\+62|62|0)[0-9]{8,12}$');
    if (!phoneRegex.hasMatch(value.replaceAll(' ', ''))) {
      return AppStrings.phoneInvalid;
    }
    return null;
  }

  /// Validates OTP length (6 digits).
  static String? otp(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.fieldRequired;
    }
    if (value.length != 6 || !RegExp(r'^\d{6}$').hasMatch(value)) {
      return 'Kode OTP harus 6 digit angka';
    }
    return null;
  }

  /// Validates that the field is not empty (alias for required).
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.fieldRequired;
    }
    if (value.trim().length < 2) {
      return 'Nama minimal 2 karakter';
    }
    return null;
  }
}
