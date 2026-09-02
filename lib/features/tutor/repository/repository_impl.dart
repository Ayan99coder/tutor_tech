import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tutor_tech/features/tutor/model/tutor_model.dart';
import 'package:tutor_tech/features/tutor/repository/repostiory.dart';

class TutorRepositoryImpl implements TutorRepository {
  final FirebaseFirestore _firestore;

  TutorRepositoryImpl(this._firestore);

  @override
  Future<TutorModel?> getTutorById(String id) async {
    final tutor = await _firestore.collection('tutor').doc(id).get();
    if(tutor.exists && tutor.data() != null){
      return TutorModel.fromJson(tutor.data()!);
    }
    return null;
  }
}
