import 'package:tutor_tech/features/student/model/student_model.dart';

abstract class StudentRepository {
  Future<StudentModel?> getStudentById (String id);
  Future<List<StudentModel>> getAllStudents();
}

