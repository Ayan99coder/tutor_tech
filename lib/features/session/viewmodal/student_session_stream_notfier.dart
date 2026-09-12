import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutor_tech/core/utils/utils/cache_extension.dart';
import 'package:tutor_tech/features/session/modal/session_modal.dart';
import 'package:tutor_tech/features/session/provider/session_provider.dart';
import 'package:tutor_tech/features/session/repository/session_repo.dart';

class StudentSessionStreamNotifier
    extends AutoDisposeFamilyStreamNotifier<List<SessionModel>, String> {
  late final SessionRepo repo;

  @override
  Stream<List<SessionModel>> build(String id) {
    ref.cacheFor(const Duration(minutes: 5));
    repo = ref.read(sessionRepoProvider);
    return repo.watchStudentSessions(id);
  }
}
