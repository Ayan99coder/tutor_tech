import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tutor_tech/features/student/provider/student_provider.dart';
import 'package:tutor_tech/features/student/repostiory/repository.dart';
import 'package:tutor_tech/features/student/viewmodal/student_state.dart';

class StudentNotifier extends FamilyAsyncNotifier<StudentState, String> {
  late final StudentRepository repo;

  @override
  Future<StudentState> build(String id) async {
    repo = ref.read(studentRepoProvider);
    getStudentById();
    getAssignedTutor();
    return StudentState(

    );
  }

  Future<void> getStudentById() async {
    final data = await repo.getStudentById(arg);
    state = AsyncData(state.requireValue.copyWith(student: data));
  }

  Future<void> getAssignedTutor() async {
    final data = await repo.getAssignedTutors(arg);
    state = AsyncData(state.requireValue.copyWith(assignedTutors: data));
  }
}
