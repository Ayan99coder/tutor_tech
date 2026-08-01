import 'package:tutor_tech/features/auth/modal/usermodal.dart';

abstract class AuthRepository {
Future<UserModel> signInWithEmail(String email,String password);
}