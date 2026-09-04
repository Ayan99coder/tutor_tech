import 'package:tutor_tech/features/tutor/model/tutor_model.dart';

abstract class SessionRepo{
  Future<List<TutorModel>?> getTutorsBySubject(String subject);
}