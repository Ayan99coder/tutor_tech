
import 'package:tutor_tech/features/tutor/model/tutor_model.dart';

abstract class TutorRepository {
  Future<TutorModel?> getTutorById(String id);
}
