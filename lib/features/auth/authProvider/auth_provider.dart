import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutor_tech/core/provider/third_party_provider.dart';
import 'package:tutor_tech/features/auth/repository/auth_repository.dart';
import 'package:tutor_tech/features/auth/repository/auth_repository_impl.dart';
import 'package:tutor_tech/features/auth/viewmodal/auth_notifier.dart';
import 'package:tutor_tech/features/auth/viewmodal/auth_state.dart';

final authRepoProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.read(fireStoreProvider),
    ref.read(firebaseAuthProvider),
  );
});
final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
