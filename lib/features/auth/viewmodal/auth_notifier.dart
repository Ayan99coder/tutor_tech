import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutor_tech/features/auth/authProvider/auth_provider.dart';

import 'package:tutor_tech/features/auth/viewmodal/auth_state.dart';

import '../repository/auth_repository.dart';

class AuthNotifier extends AsyncNotifier<AuthState> {
  late AuthRepository repo;

  @override
  FutureOr<AuthState> build() {
    repo = ref.read(authRepoProvider);
    return AuthState();
  }

}
