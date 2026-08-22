import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutor_tech/features/session/modal/session_repo.dart';
import 'package:tutor_tech/features/session/provider/session_provider.dart';
import 'package:tutor_tech/features/session/viewmodal/session_state.dart';

enum SessionTargetType { student, tutor, admin }

class SessionTarget {
  final SessionTargetType type;
  final String? id;

  const SessionTarget({required this.type, this.id});
}

class SessionNotifier extends FamilyNotifier<SessionState, SessionTarget> {
  late SessionRepository repo;

  @override
  SessionState build(SessionTarget target) {
    repo = ref.read(sessionRepo);
    return SessionState();
  }
}
