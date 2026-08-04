import 'package:tutor_tech/features/auth/modal/usermodal.dart';

import '../../student/model/student_model.dart';

abstract class AuthRepository {
  Future<UserModel> registerStudent({
    required String fullName,
    required String email,
    required String password,
    required AgeGroup ageGroup,
    required List<String> subjects,
    required GroupSize preferredGroupSize,
    required CommunicationPref communicationPref,
    required bool isUnder13,
    String? parentEmail,
  });

  Future<UserModel> registerParents({
    required String fullName,
    required String email,
    required String password,
    required List<String> childrenEmails,
  });

  Future<UserModel> registerTutors({
    required String fullName,
    required String email,
    required String password,
    required String education,
    required String teachingExperience,
    required List<String> subjects,
    required List<String> teachingLevels,
    String? cvLink,
  });
  Future<UserModel?> getCurrentUser();
}
