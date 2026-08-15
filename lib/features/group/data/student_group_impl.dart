import 'package:cloud_firestore/cloud_firestore.dart';

import '../modal/student_group_model.dart';
import '../viewmodal/student_group_repository.dart';

class StudentGroupRepositoryImpl implements StudentGroupRepository {
  final FirebaseFirestore _firestore;

  StudentGroupRepositoryImpl(this._firestore);

  @override
  Future<StudentGroupModel> saveGroup(StudentGroupModel group) async {
    final docRef = _firestore.collection('tutorStudentGroups').doc();

    final savedGroup = StudentGroupModel(
      id: docRef.id,
      tutorId: group.tutorId,
      groupName: group.groupName,
      description: group.description,
      studentIds: group.studentIds,
      studentNames: group.studentNames,
      createdAt: group.createdAt,
    );

    await docRef.set(savedGroup.toJson());

    return savedGroup;
  }

  @override
  Future<List<StudentGroupModel>> getGroups(String tutorId) async {
    final snapshot = await _firestore
        .collection('tutorStudentGroups')
        .where('tutor_id', isEqualTo: tutorId)
        .get();

    return snapshot.docs
        .map((doc) => StudentGroupModel.fromJson(doc.data(), doc.id))
        .toList();
  }

  Future<void> deleteGroup(String groupId) async {
    await _firestore.collection('tutorStudentGroups').doc(groupId).delete();
  }
}
