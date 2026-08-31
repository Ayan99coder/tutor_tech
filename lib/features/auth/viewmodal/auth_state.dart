

import '../modal/user_model.dart';

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final UserModel? currentUser;
  final String? errorMessage;
  final int registrationStep;
  final bool isEmailVerified;
final bool isRegSuccess;
  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.isRegSuccess = false,
    this.currentUser,
    this.errorMessage,
    this.registrationStep = 0,
    this.isEmailVerified = false,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    UserModel? currentUser,
    String? errorMessage,
    int? registrationStep,
    bool? isEmailVerified,
    bool? isRegSuccess,
  }) {
    return AuthState(
      isRegSuccess: isRegSuccess??this.isRegSuccess,
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      currentUser: currentUser ?? this.currentUser,
      errorMessage: errorMessage,
      registrationStep: registrationStep ?? this.registrationStep,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }
}
