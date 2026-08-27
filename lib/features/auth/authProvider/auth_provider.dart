import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutor_tech/core/provider/third_party_provider.dart';
import 'package:tutor_tech/features/auth/repository/auth_repository.dart';
import 'package:tutor_tech/features/auth/repository/auth_repository_impl.dart';

final authRepoProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.read(fireStoreProvider), ref.read(firebaseAuthProvider));
});