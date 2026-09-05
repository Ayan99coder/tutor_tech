import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutor_tech/features/session/provider/session_provider.dart';
import 'package:tutor_tech/features/session/repository/session_repo.dart';
import 'package:tutor_tech/features/session/viewmodal/session_state.dart';
import 'package:tutor_tech/features/tutor/model/tutor_model.dart';

class SessionNotifier extends AsyncNotifier<SessionState> {
  late final SessionRepo repo;

  @override
  Future<SessionState> build() async {
    repo = ref.read(sessionRepoProvider);

    return const SessionState();
  }

  Future<void> getTutorBySubject(String subject) async {
    final currentState = state.requireValue;

    final tutors = await repo.getTutorsBySubject(subject);

    state = AsyncData(
      currentState.copyWith(
        tutors: tutors ?? [],
      ),
    );
  }

}
