import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutor_tech/features/tutor/provider/tutor_provider.dart';
import 'package:tutor_tech/features/tutor/repository/repostiory.dart';
import 'package:tutor_tech/features/tutor/viewmodal/tutor_state.dart';

import '../../student/model/student_model.dart';
import '../model/tutor_model.dart';
class TutorNotifier extends FamilyAsyncNotifier<TutorState, String?> {
  late final TutorRepository repo;

  @override
  Future<TutorState> build(String? id) async {
     ref.keepAlive();

    repo = ref.read(tutorRepoProvider);

    final results = await Future.wait([
      repo.getTutorById(id!),
      repo.getStudentsByTutor(id),
    ]);

    return TutorState(
      tutor: results[0] as TutorModel?,
      stdByTutor: results[1] as List<StudentModel>,
    );
  }
}
