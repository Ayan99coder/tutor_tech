import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutor_tech/core/provider/third_party_provider.dart';
import 'package:tutor_tech/features/session/repository/session_repo_impl.dart';
import 'package:tutor_tech/features/session/viewmodal/session_notifier.dart';
import 'package:tutor_tech/features/session/viewmodal/session_state.dart';
import 'package:tutor_tech/features/tutor/provider/tutor_provider.dart';

final sessionRepoProvider = Provider((ref) {
  return SessionRepoImpl(ref.read(tutorRepoProvider),ref.read(fireStoreProvider));
});
final sessionProvider =
AsyncNotifierProvider.autoDispose<SessionNotifier, SessionState>(
  SessionNotifier.new,
);
