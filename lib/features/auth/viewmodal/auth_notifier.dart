import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutor_tech/features/auth/viewmodal/auth_state.dart';

class AuthNotifier extends AsyncNotifier<AuthState> {
  @override
  FutureOr<AuthState> build() {
   return AuthState();
  }

}