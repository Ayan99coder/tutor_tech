import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutor_tech/features/session/modal/session_modal.dart';
import 'package:tutor_tech/features/session/provider/session_provider.dart';
import 'package:tutor_tech/features/session/repository/session_repo.dart';


class SessionStreamNotifier extends StreamNotifier<List<SessionModel>> {
  late final SessionRepo repo;

  @override
  Stream<List<SessionModel>> build() {
    repo = ref.read(sessionRepoProvider);

    return repo.watchSessions();
  }
}
