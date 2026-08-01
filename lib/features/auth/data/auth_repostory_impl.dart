import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tutor_tech/features/auth/modal/auth_repository.dart';
import 'package:tutor_tech/features/auth/modal/usermodal.dart';

class AuthRepostoryImpl extends AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepostoryImpl(this._auth, this._firestore);

  @override
  Future<UserModel> signInWithEmail(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (cred.user == null) {
      throw Exception("Sign in Failed");
    }
    final docs = await _firestore.collection('users').doc(cred.user!.uid).get();
    if (docs.exists && docs.data() != null) {
      return UserModel.fromJson(docs.data()!);
    } else {
      throw Exception('User Profile not found');
    }
  }
}
