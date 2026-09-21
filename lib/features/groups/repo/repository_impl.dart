import 'package:tutor_tech/features/groups/model/group_model.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tutor_tech/features/groups/repo/repository.dart';

class StudentGroupRepositoryImpl implements StudentGroupRepo {
  final FirebaseFirestore _firestore;

  StudentGroupRepositoryImpl(this._firestore);

  CollectionReference<Map<String, dynamic>> get _groupsCollection =>
      _firestore.collection('student_groups');

  @override
  Future<String> createGroup(StudentGroupModel groupModel) async {
    final docRef = _groupsCollection.doc();

    final group = StudentGroupModel(
      id: docRef.id,
      tutorId: groupModel.tutorId,
      groupName: groupModel.groupName,
      description: groupModel.description,
      studentIds: groupModel.studentIds,
      studentNames: groupModel.studentNames,
      createdAt: groupModel.createdAt,
    );

    await docRef.set(group.toJson());

    return docRef.id;
  }

  @override
  Future<List<StudentGroupModel>> groupsByTutorId(String tutorId) async {
    final snapshot = await _groupsCollection
        .where('tutor_id', isEqualTo: tutorId)
        .get();

    final groups = snapshot.docs
        .map((doc) => StudentGroupModel.fromJson(doc.data(), doc.id))
        .toList();

    // Dart side pe sort karo — composite index ki zaroorat nahi
    groups.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return groups;
  }

  @override
  Future<List<StudentGroupModel>> groupsByStdId(String studentId) async {
    final snapshot = await _groupsCollection
        .where('student_ids', arrayContains: studentId)
        .get();

    final groups = snapshot.docs
        .map((doc) => StudentGroupModel.fromJson(doc.data(), doc.id))
        .toList();

    // Dart side pe sort karo — composite index ki zaroorat nahi
    groups.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return groups;
  }
}
