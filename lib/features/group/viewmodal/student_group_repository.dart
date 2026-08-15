

import '../modal/student_group_model.dart';

abstract class StudentGroupRepository {
  Future<StudentGroupModel> saveGroup(StudentGroupModel group);
  Future<List<StudentGroupModel>> getGroups(String tutorId);
}
