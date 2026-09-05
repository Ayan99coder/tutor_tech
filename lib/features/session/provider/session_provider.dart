import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutor_tech/features/session/repository/session_repo_impl.dart';
import 'package:tutor_tech/features/session/viewmodal/session_notifier.dart';
import 'package:tutor_tech/features/session/viewmodal/session_state.dart';
import 'package:tutor_tech/features/tutor/provider/tutor_provider.dart';

final sessionRepoProvider = Provider((ref) {
  return SessionRepoImpl(ref.read(tutorRepoProvider));
});
final sessionProvider = AsyncNotifierProvider<SessionNotifier, SessionState>(
  SessionNotifier.new,
);
