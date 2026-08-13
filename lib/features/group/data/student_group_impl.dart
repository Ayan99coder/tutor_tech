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
}
