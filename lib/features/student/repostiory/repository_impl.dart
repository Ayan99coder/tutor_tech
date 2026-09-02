import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tutor_tech/features/student/model/student_model.dart';
import 'package:tutor_tech/features/student/repostiory/repository.dart';

class StudentRepositoryImpl implements StudentRepository{
  final FirebaseFirestore _firestore;
  StudentRepositoryImpl(this._firestore);
  @override
Future<StudentModel?> getStudentById(String id)async{
    final user = await _firestore.collection('students').doc(id).get();
    if(user.exists&&user.data() != null){
      return StudentModel.fromJson(user.data()!);
    }
    return null;
  }
}