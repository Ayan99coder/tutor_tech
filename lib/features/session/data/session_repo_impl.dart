import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tutor_tech/features/session/modal/session_model.dart';
import 'package:tutor_tech/features/session/modal/session_repo.dart';

class SessionRepoImpl implements SessionRepository{
  final FirebaseFirestore _firestore;
  SessionRepoImpl(this._firestore);
  @override
  Stream<List<SessionModel>> watchAllSessions() {
    return _firestore
        .collection('sessions')
        .orderBy('createdAt')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map(
            (doc) => SessionModel.fromJson(doc.data()),
      )
          .toList(),
    );
  }


}