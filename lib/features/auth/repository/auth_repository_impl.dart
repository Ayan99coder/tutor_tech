import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tutor_tech/features/auth/repository/auth_repository.dart';

import '../../parent/model/parent_model.dart';
import '../../student/student_model.dart';
import '../../tutor/model/tutor_model.dart';
import '../modal/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firebaseFirestore;

  AuthRepositoryImpl(this._firebaseFirestore, this._firebaseAuth);

  @override
  Future<UserModel> signInWithEmail(String email, String password) async {
    final cred = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (cred.user == null) {
      throw Exception("Sign in failed");
    }

    final doc = await _firebaseFirestore
        .collection('users')
        .doc(cred.user!.uid)
        .get();
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
    // 1. Validate under-13 requirements
    if (isUnder13 && (parentEmail == null || parentEmail.trim().isEmpty)) {
      throw Exception(
        'Parent email is required for users under 13.',
      );
    }

    // Keep parent email null for users who are 13+
    final normalizedParentEmail =
    isUnder13 ? parentEmail!.trim() : null;

    UserCredential? credential;

    try {
      // 2. Create Firebase Authentication user
      credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final firebaseUser = credential.user;

      if (firebaseUser == null) {
        throw Exception('Registration failed.');
      }

      // 3. Generate one timestamp for both models
      final now = DateTime.now();

      // 4. Create UserModel
      final newUser = UserModel(
        id: firebaseUser.uid,
        email: email.trim(),
        fullName: fullName.trim(),
        role: UserRole.student,
        isActive: false,
        createdAt: now,
      );

      // 5. Create StudentModel
      final newStudent = StudentModel(
        id: firebaseUser.uid,
        userId: firebaseUser.uid,
        fullName: fullName.trim(),
        email: email.trim(),
        ageGroup: ageGroup,
        selectedSubjects: subjects,
        preferredGroupSize: preferredGroupSize,
        communicationPreference: communicationPref,
        isUnder13: isUnder13,
        parentEmail: normalizedParentEmail,
        applicationStatus: ApplicationStatus.pending,
        createdAt: now,
      );

      // 6. Create Firestore references
      final userRef = _firebaseFirestore
          .collection('users')
          .doc(firebaseUser.uid);

      final studentRef = _firebaseFirestore
          .collection('students')
          .doc(firebaseUser.uid);

      // 7. Create Firestore batch
      final batch = _firebaseFirestore.batch();

      batch.set(
        userRef,
        newUser.toJson(),
      );

      batch.set(
        studentRef,
        newStudent.toJson(),
      );

      // 8. Commit both Firestore writes together
      await batch.commit();

      // 9. Send email verification
      if (!firebaseUser.emailVerified) {
        await firebaseUser.sendEmailVerification();
      }

      // 10. Return created user
      return newUser;
    } catch (e) {
      // Firebase Auth user was created but Firestore failed.
      // Try to clean up the Auth account.
      if (credential?.user != null) {
        try {
          await credential!.user!.delete();
        } catch (_) {
          // Ignore cleanup error.
        }
      }

      rethrow;
    }

  }
  @override
  Future<UserModel> registerParent({
    required String fullName,
    required String email,
    required String password,
    required List<String> childrenEmails,
  }) async {
    UserCredential? credential;

    try {
      // 1. Create Firebase Authentication account
      credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final firebaseUser = credential.user;

      if (firebaseUser == null) {
        throw Exception('Registration failed.');
      }

      // 2. Generate one timestamp
      final now = DateTime.now();

      // 3. Create UserModel
      final newUser = UserModel(
        id: firebaseUser.uid,
        email: email.trim(),
        fullName: fullName.trim(),
        role: UserRole.parent,
        isActive: true,
        createdAt: now,
      );

      // 4. Find children
      final childrenIds = <String>[];

      for (final childEmail in childrenEmails) {
        final normalizedEmail = childEmail.trim();

        if (normalizedEmail.isEmpty) {
          continue;
        }

        final snapshot = await _firebaseFirestore
            .collection('users')
            .where(
          'email',
          isEqualTo: normalizedEmail,
        )
            .where(
          'role',
          isEqualTo: UserRole.student.name,
        )
            .limit(1)
            .get();

        if (snapshot.docs.isNotEmpty) {
          final childId = snapshot.docs.first.id;

          childrenIds.add(childId);
        }
      }

      // 5. Create ParentModel
      final newParent = ParentModel(
        id: firebaseUser.uid,
        userId: firebaseUser.uid,
        fullName: fullName.trim(),
        email: email.trim(),
        childrenIds: childrenIds,
        createdAt: now,
      );

      // 6. Create Firestore batch
      final batch = _firebaseFirestore.batch();

      // User document
      final userRef = _firebaseFirestore
          .collection('users')
          .doc(firebaseUser.uid);

      batch.set(
        userRef,
        newUser.toJson(),
      );

      // Parent document
      final parentRef = _firebaseFirestore
          .collection('parents')
          .doc(firebaseUser.uid);

      batch.set(
        parentRef,
        newParent.toJson(),
      );

      // 7. Link parent with all children
      for (final childId in childrenIds) {
        final studentRef = _firebaseFirestore
            .collection('students')
            .doc(childId);

        batch.update(
          studentRef,
          {
            'parentId': firebaseUser.uid,
          },
        );
      }

      // 8. Commit all Firestore writes together
      await batch.commit();

      // 9. Send email verification
      if (!firebaseUser.emailVerified) {
        await firebaseUser.sendEmailVerification();
      }

      // 10. Return UserModel
      return newUser;
    } catch (e) {
      // If Auth account was created but Firestore failed,
      // try to remove the Auth account.
      if (credential?.user != null) {
        try {
          await credential!.user!.delete();
        } catch (_) {
          // Ignore cleanup error.
        }
      }

      rethrow;
    }
  }
  @override
  Future<UserModel> registerTutor({
    required String fullName,
    required String email,
    required String password,
    required String education,
    required String teachingExperience,
    required List<String> subjects,
    required List<String> teachingLevels,
    String? cvLink,
  }) async {
    UserCredential? credential;

    try {
      // 1. Create Firebase Authentication account
      credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final firebaseUser = credential.user;

      if (firebaseUser == null) {
        throw Exception('Registration failed.');
      }

      // 2. Generate one timestamp
      final now = DateTime.now();

      // 3. Create UserModel
      final newUser = UserModel(
        id: firebaseUser.uid,
        email: email.trim(),
        fullName: fullName.trim(),
        role: UserRole.tutor,
        isActive: false,
        createdAt: now,
      );

      // 4. Create TutorModel
      final newTutor = TutorModel(
        id: firebaseUser.uid,
        userId: firebaseUser.uid,
        fullName: fullName.trim(),
        email: email.trim(),
        availability: [],
        education: education.trim(),
        teachingExperience: teachingExperience.trim(),
        subjectExpertise: subjects,
        teachingLevels: teachingLevels,
        cvLink: cvLink?.trim(),
        applicationStatus: TutorApplicationStatus.pending,
        createdAt: now,
      );

      // 5. Create Firestore references
      final userRef = _firebaseFirestore
          .collection('users')
          .doc(firebaseUser.uid);

      final tutorRef = _firebaseFirestore
          .collection('tutors')
          .doc(firebaseUser.uid);

      // 6. Create Firestore batch
      final batch = _firebaseFirestore.batch();

      // Save common user data
      batch.set(
        userRef,
        newUser.toJson(),
      );

      // Save tutor-specific data
      batch.set(
        tutorRef,
        newTutor.toJson(),
      );

      // 7. Commit both writes together
      await batch.commit();

      // 8. Send email verification
      if (!firebaseUser.emailVerified) {
        await firebaseUser.sendEmailVerification();
      }

      // 9. Return UserModel for AuthState
      return newUser;
    } catch (e) {
      // Cleanup Auth account if Firestore operation fails
      if (credential?.user != null) {
        try {
          await credential!.user!.delete();
        } catch (_) {
          // Ignore cleanup failure
        }
      }

      rethrow;
    }
  }
  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
  @override
  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = _firebaseAuth.currentUser;

    if (firebaseUser == null) {
      return null;
    }

    final doc = await _firebaseFirestore
        .collection('users')
        .doc(firebaseUser.uid)
        .get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return UserModel.fromJson(doc.data()!);
  }
  @override
  Stream<UserModel?> authStateChanges() {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) {
        return null;
      }

      final doc = await _firebaseFirestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      return UserModel.fromJson(doc.data()!);
    });
  }
  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

}
