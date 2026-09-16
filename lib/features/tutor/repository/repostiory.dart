import 'package:tutor_tech/features/tutor/model/tutor_model.dart';

import '../../student/model/student_model.dart';

abstract class TutorRepository {
  Future<TutorModel?> getTutorById(String id);

  Future<List<TutorModel>?> getAllTutors();

  Future<List<StudentModel>> getStudentsByTutor(
    String id
  );
}
