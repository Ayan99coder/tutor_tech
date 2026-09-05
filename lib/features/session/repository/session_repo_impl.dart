import 'package:tutor_tech/features/session/repository/session_repo.dart';
import 'package:tutor_tech/features/tutor/model/tutor_model.dart';
import 'package:tutor_tech/features/tutor/repository/repostiory.dart';

class SessionRepoImpl implements SessionRepo{
  final TutorRepository repo;
  SessionRepoImpl(this.repo);
  @override
  Future<List<TutorModel>?> getTutorsBySubject(String subject) async {
    final tutors = await repo.getAllTutors();

    final normalizedSubject = subject.trim().toLowerCase();

    final filteredTutors = tutors?.where((tutor) {
      return tutor.subjectExpertise.any(
            (sbj) => sbj.trim().toLowerCase() == normalizedSubject,
      );
    }).toList();


    if (filteredTutors == null || filteredTutors.isEmpty) {
      return tutors;
    }

    return filteredTutors;
  }

}