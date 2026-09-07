import 'package:tutor_tech/features/tutor/model/tutor_model.dart';

import '../../student/model/student_model.dart';
import '../modal/session_modal.dart';

abstract class SessionRepo{
  Future<List<TutorModel>?> getTutorsBySubject(String subject);
  Future<List<StudentModel>>? getStudentBySubject(String subject);
  Future<SessionModel> createSession(SessionModel session);
}