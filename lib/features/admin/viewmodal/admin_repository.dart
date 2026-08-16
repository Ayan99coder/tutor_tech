import 'package:tutor_tech/features/student/model/student_model.dart';
import 'package:tutor_tech/features/tutor/model/tutor_model.dart';

abstract class AdminRepository {
  Future<List<TutorModel>> getFilteredTutor(String subject);
  Future<List<StudentModel>> getFilteredStudent(String tutorId);
}
