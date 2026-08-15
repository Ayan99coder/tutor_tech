import 'dart:async';

import 'package:tutor_tech/features/admin/viewmodal/admin_repository.dart';
import 'package:tutor_tech/features/tutor/model/tutor_model.dart';
import 'package:tutor_tech/features/tutor/model/tutor_repository.dart';

class AdminRepositoryImpl implements AdminRepository {
  TutorRepository tutorRepository;

  AdminRepositoryImpl(this.tutorRepository);

  @override
  Future<List<TutorModel>> getFilteredTutor(String subject) async {
    final tutors = await tutorRepository.getAllTutors();
    final filteredTutors = tutors
        .where(
          (tutor) => tutor.subjectExpertise.any(
            (expertise) =>
                expertise.toLowerCase().contains(subject.toLowerCase()) ||
                subject.toLowerCase().contains(expertise.toLowerCase()),
          ),
        )
        .toList();
    return filteredTutors.isNotEmpty ? filteredTutors : tutors;
  }
}
