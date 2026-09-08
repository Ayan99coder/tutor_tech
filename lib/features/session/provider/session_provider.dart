import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutor_tech/core/provider/third_party_provider.dart';
import 'package:tutor_tech/features/session/modal/session_modal.dart';
import 'package:tutor_tech/features/session/repository/session_repo_impl.dart';
import 'package:tutor_tech/features/session/viewmodal/session_notifier.dart';
import 'package:tutor_tech/features/session/viewmodal/session_state.dart';
import 'package:tutor_tech/features/session/viewmodal/student_session_stream_notfier.dart';
import 'package:tutor_tech/features/session/viewmodal/tutor_session_stream_notifier.dart';
import 'package:tutor_tech/features/tutor/provider/tutor_provider.dart';

final sessionRepoProvider = Provider((ref) {
  return SessionRepoImpl(
    ref.read(tutorRepoProvider),
    ref.read(fireStoreProvider),
  );
});
final sessionProvider = AsyncNotifierProvider<SessionNotifier, SessionState>(
  SessionNotifier.new,
);

final tutorSessions =
    StreamNotifierProviderFamily<
      TutorSessionStreamNotifier,
      List<SessionModel>,
      String
    >(TutorSessionStreamNotifier.new);
final studentSessions =
    StreamNotifierProviderFamily<
      StudentSessionStreamNotifier,
      List<SessionModel>,
      String
    >(StudentSessionStreamNotifier.new);
