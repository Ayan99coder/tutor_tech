import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tutor_tech/features/auth/modal/auth_repository.dart';
import 'package:tutor_tech/features/parent/model/parent_model.dart';
import 'package:tutor_tech/features/tutor/model/tutor_model.dart';

import '../../student/model/student_model.dart';
import '../modal/usermodal.dart';

class AuthRepositoryImpl extends AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepositoryImpl(this._auth, this._firestore);
  @override
  Future<UserModel> signInWithEmail(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    if (cred.user == null) {
      throw Exception("Sign in failed");
    }

    final doc = await _firestore.collection('users').doc(cred.user!.uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromJson(doc.data()!);
    } else {
      throw Exception("User profile not found");
    }
  }

  @override
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
      throw Exception("Parents Email must be Provide!");
    }
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (cred.user == null) {
      throw Exception("register failed please try again");
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

  @override
  Future<UserModel> registerParents({
    required String fullName,
    required String email,
    required String password,
    required List<String> childrenEmails,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (cred.user == null) throw Exception('');
    final newUser = UserModel(
      id: cred.user!.uid,
      email: email,
      fullName: fullName,
      role: UserRole.parent,
      createdAt: DateTime.now(),
      applicationStatus: ApplicationStatus.pending,
    );
    await _firestore.collection('users').doc(newUser.id).set(newUser.toJson());
    List<String> childrenIds = [];
    for (final childEmail in childrenEmails) {
      final snapshot = await _firestore
          .collection("users")
          .where('emails', isEqualTo: childEmail)
          .where('role', isEqualTo: UserRole.student.name)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        childrenIds.add(snapshot.docs.first.id);
        await _firestore
            .collection('students')
            .doc(snapshot.docs.first.id)
            .update({'parent_id': newUser.id});
      }
    }
    final newParent = ParentModel(
      id: newUser.id,
      userId: newUser.id,
      fullName: fullName,
      email: email,
      childrenIds: childrenIds,
      createdAt: DateTime.now(),
    );
    await _firestore
        .collection('parent')
        .doc(newParent.id)
        .set(newParent.toJson());
    return newUser;
  }

  @override
  Future<UserModel> registerTutors({
    required String fullName,
    required String email,
    required String password,
    required String education,
    required String teachingExperience,
    required List<String> subjects,
    required List<String> teachingLevels,
    String? cvLink,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (cred.user == null) throw Exception("");
    final newUser = UserModel(
      id: cred.user!.uid,
      email: email,
      fullName: fullName,
      role: UserRole.tutor,
      createdAt: DateTime.now(),
      applicationStatus: ApplicationStatus.pending,
    );
    final newTutor = TutorModel(
      id: newUser.id,
      userId: newUser.id,
      fullName: fullName,
      email: email,
      availability: [],
      education: education,
      teachingExperience: teachingExperience,
      subjectExpertise: subjects,
      teachingLevels: teachingLevels,
      createdAt: DateTime.now(),
    );
    await _firestore.collection('users').doc(newUser.id).set(newUser.toJson());
    await _firestore.collection('tutor').doc().set(newTutor.toJson());
    return newUser;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromJson(doc.data()!);
      }
    }
    return null;
  }
}
