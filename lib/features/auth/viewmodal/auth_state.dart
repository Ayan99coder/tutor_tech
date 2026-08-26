import '../modal/user_model.dart';

class AuthState {
  final UserModel? currentUser;
  final bool isEmailVerified;

  const AuthState({this.currentUser, this.isEmailVerified = false});

  AuthState copyWith({
    UserModel? currentUser,
    bool? isEmailVerified,
    bool clearUser = false,
  }) {
    return AuthState(
      currentUser: clearUser ? null : (currentUser ?? this.currentUser),
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }
}
