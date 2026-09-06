import 'package:tutor_tech/features/student/model/student_model.dart';
import 'package:tutor_tech/features/tutor/model/tutor_model.dart';

abstract class StudentRepository{
  Future<StudentModel?> getStudentById(String id);
  Future<List<TutorModel>> getAssignedTutors(String id);

}