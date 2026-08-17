import 'session_model.dart';

abstract class SessionRepository{
  Stream<List<SessionModel>> watchAllSessions();
}