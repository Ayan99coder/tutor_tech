import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutor_tech/core/provider/provider.dart';
import 'package:tutor_tech/features/auth/data/auth_repository_impl.dart';
import 'package:tutor_tech/features/auth/viewmodal/auth_state.dart';
import 'package:tutor_tech/features/auth/viewmodal/auth_view_modal.dart';

final authRepoProvider = Provider((ref) {
  return AuthRepositoryImpl(
    ref.read(firebaseAuthProvider),
    ref.read(firebaseFirestoreProvider),
  );
});

final authViewModalProvider = StateNotifierProvider<AuthViewModal, AuthState>((ref) {
  return AuthViewModal(ref.read(authRepoProvider));
});
