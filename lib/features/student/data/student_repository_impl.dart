import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tutor_tech/features/student/model/student_model.dart';
import 'package:tutor_tech/features/student/model/student_repository.dart';

class StudentRepositoryImpl implements StudentRepository{
  final FirebaseFirestore _firestore;
  StudentRepositoryImpl(this._firestore);
  @override
  Future<StudentModel?> getStudentById(String id)async{
    final data = await _firestore.collection('student').doc(id).get();
    if(data.exists && data.data() != null){
      return StudentModel.fromJson(data.data()!);
    }
    return null;
  }
}