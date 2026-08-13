

import '../modal/student_group_model.dart';

abstract class StudentGroupRepository {
  Future<StudentGroupModel> saveGroup(StudentGroupModel group);
}
