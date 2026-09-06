import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutor_tech/features/student/model/student_model.dart';

import 'package:tutor_tech/features/student/provider/student_provider.dart';
import 'package:tutor_tech/features/student/repostiory/repository.dart';
import 'package:tutor_tech/features/student/viewmodal/student_state.dart';
import 'package:tutor_tech/features/tutor/model/tutor_model.dart';

class StudentNotifier extends FamilyAsyncNotifier<StudentState, String> {
  late final StudentRepository repo;

  @override
  Future<StudentState> build(String id) async {
    repo = ref.read(studentRepoProvider);
    final results = await Future.wait([
      repo.getStudentById(id),
      repo.getAssignedTutors(id),
    ]);
    return StudentState(
      student: results[0] as StudentModel,
      assignedTutors: results[1] as List<TutorModel>,
    );
  }
}
