import '../model/group_model.dart';

abstract class StudentGroupRepo {
  Future<String> createGroup(StudentGroupModel groupModel);

  Future<List<StudentGroupModel>> groupsByTutorId(String id);

  Future<List<StudentGroupModel>> groupsByStdId(String id);
}
