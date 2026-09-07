import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutor_tech/features/session/modal/session_modal.dart';
import 'package:tutor_tech/features/session/provider/session_provider.dart';
import 'package:tutor_tech/features/session/repository/session_repo.dart';
import 'package:tutor_tech/features/session/viewmodal/session_state.dart';
import 'package:tutor_tech/features/tutor/model/tutor_model.dart';

class SessionNotifier extends AutoDisposeAsyncNotifier<SessionState> {
  late final SessionRepo repo;

  @override
  Future<SessionState> build() async {
    ref.onDispose(() {});
    repo = ref.read(sessionRepoProvider);

    return const SessionState();
  }

  Future<void> getTutorBySubject(String subject) async {
    final currentState = state.requireValue;

    final tutors = await repo.getTutorsBySubject(subject);

    state = AsyncData(currentState.copyWith(tutors: tutors ?? []));
  }

  Future<void> getStudentBySubject(String sub) async {
    final student = await repo.getStudentBySubject(sub);
    state = AsyncData(
      state.requireValue.copyWith(studentsBySubject: student ?? []),
    );
  }

  Future<void> saveSession(SessionModel session) async {
    state = await AsyncValue.guard(() async {
      final sessionTitle = await repo.createSession(session);
      return  SessionState(
        isCreateSuccess: true,
        createdSessionTitle:sessionTitle.title ,
      );
    });
  }
}
