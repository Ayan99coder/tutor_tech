import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutor_tech/core/provider/provider.dart';
import 'package:tutor_tech/features/session/data/session_repo_impl.dart';
import 'package:tutor_tech/features/session/modal/session_repo.dart';
import 'package:tutor_tech/features/session/viewmodal/session_notifier.dart';
import 'package:tutor_tech/features/session/viewmodal/session_state.dart';

final sessionRepo = Provider<SessionRepository>((ref) {
  return SessionRepoImpl(ref.read(firebaseFirestoreProvider));
});
final sessionProvider =  NotifierProvider.family<SessionNotifier, SessionState,SessionTarget>(
  SessionNotifier.new,
);
