import 'package:firebase_auth/firebase_auth.dart';

class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email must not be empty';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password must not be empty';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName must not be empty';
    }
    return null;
  }

  static bool checkIsUnder13(DateTime dob) {
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age < 13;
  }
}
class AuthErrorHandler {
  String getMessage(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-credential':
          return 'Email or password is incorrect.';

        case 'email-already-in-use':
          return 'An account already exists with this email.';

        case 'weak-password':
          return 'Please choose a stronger password.';

        case 'invalid-email':
          return 'Please enter a valid email address.';

        case 'user-not-found':
          return 'No account found with this email.';

        case 'wrong-password':
          return 'The password is incorrect.';

        case 'network-request-failed':
          return 'Please check your internet connection.';

        default:
          return 'Something went wrong. Please try again.';
      }
    }

    return 'Something went wrong. Please try again.';
  }
}