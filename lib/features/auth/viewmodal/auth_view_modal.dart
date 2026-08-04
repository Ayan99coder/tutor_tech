import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutor_tech/features/auth/modal/auth_repository.dart';
import 'package:tutor_tech/features/auth/viewmodal/auth_state.dart';
import 'package:tutor_tech/features/student/model/student_model.dart';

class AuthViewModal extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthViewModal(this._authRepository) : super(const AuthState());

  Future<void> checkAuthState() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          currentUser: user,
        );
      } else {
        state = state.copyWith(
          isAuthenticated: false,
          isLoading: false,
          currentUser: null,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        isAuthenticated: false,
      );
    }
  }

  Future<void> registerStudent({
    required String fullName,
    required String email,
    required String password,
    required AgeGroup ageGroup,
    required List<String> subjects,
    required GroupSize preferredGroupSize,
    required CommunicationPref communicationPref,
    required bool isUnder13,
    String? parentEmail,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _authRepository.registerStudent(
        fullName: fullName,
        email: email,
        password: password,
        ageGroup: ageGroup,
        subjects: subjects,
        preferredGroupSize: preferredGroupSize,
        communicationPref: communicationPref,
        isUnder13: isUnder13,
        parentEmail: parentEmail,
      );
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        currentUser: user,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}
