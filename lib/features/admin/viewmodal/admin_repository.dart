import 'package:tutor_tech/features/tutor/model/tutor_model.dart';

abstract class AdminRepository {
  Future<List<TutorModel>> getFilteredTutor(String subject);
}
