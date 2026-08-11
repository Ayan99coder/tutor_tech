import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tutor_tech/features/tutor/model/tutor_model.dart';
import 'package:tutor_tech/features/tutor/model/tutor_repository.dart';

class TutorRepositoryImpl implements TutorRepository {
  FirebaseFirestore _firestore;

  TutorRepositoryImpl(this._firestore);

  Future<TutorModel?> getTutorById(String id) async {
    final tutorDoc = await _firestore.collection('tutor').doc(id).get();
    if (tutorDoc.exists && tutorDoc.data() != null) {
      return TutorModel.fromJson(tutorDoc.data()!);
    }
    return null;
  }

  @override
  @override
  Stream<List<Map<String, String>>> watchAssignedStudents(String tutorId) {

    return _firestore
        .collection('students')
        .where('tutorId', isEqualTo: tutorId)
        .snapshots()
        .map((snapshot) {
          final List<Map<String, String>> assignedStudents = [];

          for (final doc in snapshot.docs) {
            final data = doc.data();

            final name =
                data['fullName']?.toString() ??
                data['full_name']?.toString() ??
                'Student';

            final email = data['email']?.toString() ?? '';

            final userId =
                data['userId']?.toString() ?? data['user_id']?.toString() ?? '';

            assignedStudents.add({
              'id': doc.id,
              'user_id': userId,
              'name': name,
              'email': email,
            });
          }

          return assignedStudents;
        });
  }
}
