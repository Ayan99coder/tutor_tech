import '../modal/student_group_model.dart';

abstract class StudentGroupRepository {
  Future<List<StudentGroupModel>> getGroupsByTutor(String tutorId);

  Future<List<StudentGroupStudentModel>> getStudentsByTutor(String tutorId);

  Future<void> createGroup(StudentGroupModel group);
}
