import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tutor_tech/features/auth/modal/auth_repository.dart';

import '../../student/model/student_model.dart';
import '../modal/usermodal.dart';

class AuthRepositoryImpl extends AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepositoryImpl(this._auth, this._firestore);

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
  }) async {
    if (isUnder13 && (parentEmail == null || parentEmail.isEmpty)) {
      throw "Parents Email must be Provide!";
    }
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (cred.user == null) {
      throw "register failed please try again";
    }
    final newUser = UserModel(
      id: cred.user!.uid,
      email: email,
      fullName: fullName,
      role: UserRole.student,
      createdAt: DateTime.now(),
      applicationStatus: ApplicationStatus.pending,
    );
    final userData = newUser.toJson();
    if (isUnder13) {
      userData['isUnder13'] = true;
      userData['parentEmail'] = parentEmail;
    }
    await _firestore.collection("users").doc(newUser.id).set(userData);
    final newStudent = StudentModel(
      id: newUser.id,
      userId: newUser.id,
      fullName: fullName,
      email: email,
      ageGroup: ageGroup,
      selectedSubjects: subjects,
      preferredGroupSize: preferredGroupSize,
      isUnder13: isUnder13,
      createdAt: DateTime.now(),
    );
    await _firestore
        .collection("students")
        .doc(newStudent.id)
        .set(newStudent.toJson());
    if (!cred.user!.emailVerified) {
      await cred.user!.sendEmailVerification();
    }
    return newUser;
  }
}
