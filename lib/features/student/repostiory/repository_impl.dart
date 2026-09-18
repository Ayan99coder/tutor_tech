import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tutor_tech/features/student/model/student_model.dart';
import 'package:tutor_tech/features/student/repostiory/repository.dart';
import 'package:tutor_tech/features/tutor/model/tutor_model.dart';
import 'package:tutor_tech/features/tutor/repository/repostiory.dart';

class StudentRepositoryImpl implements StudentRepository {
  final FirebaseFirestore _firestore;
  final TutorRepository _tutorRepository;

  StudentRepositoryImpl(this._firestore, this._tutorRepository);

  // ── Single student fetch ────────────────────────────────────────────────
  @override
  Future<StudentModel?> getStudentById(String id) async {
    final user = await _firestore.collection('students').doc(id).get();
    if (user.exists && user.data() != null) {
      return StudentModel.fromJson({...user.data()!, 'id': user.id});
    }
    return null;
  }

  // ── Assigned tutors (legacy) ────────────────────────────────────────────
  @override
  Future<List<TutorModel>> getAssignedTutors(String id) async {
    final student = await getStudentById(id);

    if (student == null) {
      return [];
    }

    final tutors = await _tutorRepository.getAllTutors();
    if (tutors == null) {
      return [];
    }
    return tutors
        .where(
          (tutor) => tutor.subjectExpertise.any(
            (subject) => student.selectedSubjects.contains(subject),
          ),
        )
        .toList();
  }

  // ── Cursor-based Pagination ────────────────────────────────────────────
  /// Yeh query KISI composite index ki zaroorat NAHI hai.
  ///
  /// Firestore mein single-field index automatically bana hota hai:
  ///   - 'tutorId'   → auto-indexed ✅
  ///   - 'createdAt' → auto-indexed ✅
  ///
  /// Dono combine hone par bhi index nahi chahiye kyunki:
  ///   - 'tutorId' equality filter hai
  ///   - 'createdAt' ordering hai
  ///   → Firestore yeh automatically handle karta hai ✅
  @override
  Future<StudentsPage> getStudentsByTutorPaginated(
    String tutorId, {
    DocumentSnapshot? lastDocument,
    int limit = 20,
  }) async {
    // ── Base query — itna simple hai! ──────────────────────────────────
    var query = _firestore
        .collection('students')
        .where('tutorId', isEqualTo: tutorId) // ← single where ✅
        .orderBy('createdAt', descending: true) // ← newest students first
        .limit(limit);

    // ── Cursor: sirf next pages par apply hoga ──────────────────────────
    // Pehle page ke liye lastDocument = null → yeh block skip hoga
    // Agli pages ke liye lastDocument = previous page ka aakhri doc
    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
      // Firestore internally yeh karta hai:
      // "lastDocument ki position ke BAAD wale documents do"
      // No scanning from the start — direct jump to cursor position
    }

    final snap = await query.get();

    return StudentsPage(
      students: snap.docs
          .map((doc) => StudentModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList(),

      // Yeh cursor ban jayega agli page ke liye
      lastDocument: snap.docs.isNotEmpty ? snap.docs.last : null,

      // Logic: agar humne 20 maange aur 20 mile → aur hain
      //        agar humne 20 maange aur 7 mile  → khatam ho gaye
      hasMore: snap.docs.length == limit,
    );
  }

  // ── Assign tutor to student ─────────────────────────────────────────────
  /// Admin panel ya matching system se call ho — student ko tutor assign karo.
  /// Sirf 'tutorId' field update hota hai — baaki fields safe hain.
  @override
  Future<void> assignTutorToStudent({
    required String studentId,
    required String tutorId,
  }) async {
    await _firestore.collection('students').doc(studentId).update({
      'tutorId': tutorId,
    });
  }
}

