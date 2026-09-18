import 'package:cloud_firestore/cloud_firestore.dart';

enum AgeGroup {
  primary,
  elevenPlus,
  gcse,
  aLevel,
  btec,
}

enum GroupSize {
  oneToOne,
  oneToFive,
  oneToTen,
}

enum CommunicationPref {
  parentOnly,
  studentOnly,
  both,
}
enum ApplicationStatus{
  pending,
  approved,
  rejected,
}
class StudentModel {
  final String id;
  final String userId;
  final String fullName;
  final String email;

  final AgeGroup ageGroup;
  final List<String> selectedSubjects;
  final GroupSize preferredGroupSize;
  final CommunicationPref communicationPreference;

  final bool isUnder13;
  final String? parentEmail;

  final ApplicationStatus applicationStatus;
  final DateTime createdAt;

  /// Jab admin/tutor kisi student ko assign kare tab yeh set hoga.
  /// Registration ke waqt null hota hai.
  /// Yahi field simple pagination query allow karta hai:
  ///   .where('tutorId', isEqualTo: tutorId) — NO composite index needed!
  final String? tutorId;

  const StudentModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.email,
    required this.ageGroup,
    required this.selectedSubjects,
    required this.preferredGroupSize,
    required this.communicationPreference,
    required this.isUnder13,
    this.parentEmail,
    required this.applicationStatus,
    required this.createdAt,
    this.tutorId,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,

      ageGroup: AgeGroup.values.firstWhere(
            (e) => e.name == json['ageGroup'],
      ),

      selectedSubjects:
      List<String>.from(json['selectedSubjects'] ?? []),

      preferredGroupSize: GroupSize.values.firstWhere(
            (e) => e.name == json['preferredGroupSize'],
      ),

      communicationPreference: CommunicationPref.values.firstWhere(
            (e) => e.name == json['communicationPreference'],
      ),

      isUnder13: json['isUnder13'] as bool? ?? false,

      parentEmail: json['parentEmail'] as String?,

      applicationStatus: ApplicationStatus.values.firstWhere(
            (e) => e.name == json['applicationStatus'],
      ),

      createdAt: (json['createdAt'] as Timestamp).toDate(),

      // Null-safe: purane documents mein field nahi hogi
      tutorId: json['tutorId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'fullName': fullName,
      'email': email,
      'ageGroup': ageGroup.name,
      'selectedSubjects': selectedSubjects,
      'preferredGroupSize': preferredGroupSize.name,
      'communicationPreference': communicationPreference.name,
      'isUnder13': isUnder13,
      'parentEmail': parentEmail,
      'applicationStatus': applicationStatus.name,
      'createdAt': Timestamp.fromDate(createdAt),
      // null hone par Firestore mein field nahi jayegi (bandwidth save)
      if (tutorId != null) 'tutorId': tutorId,
    };
  }

  StudentModel copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? email,
    AgeGroup? ageGroup,
    List<String>? selectedSubjects,
    GroupSize? preferredGroupSize,
    CommunicationPref? communicationPreference,
    bool? isUnder13,
    String? parentEmail,
    ApplicationStatus? applicationStatus,
    DateTime? createdAt,
    String? tutorId,
    bool clearTutorId = false,
  }) {
    return StudentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      ageGroup: ageGroup ?? this.ageGroup,
      selectedSubjects: selectedSubjects ?? this.selectedSubjects,
      preferredGroupSize:
      preferredGroupSize ?? this.preferredGroupSize,
      communicationPreference:
      communicationPreference ?? this.communicationPreference,
      isUnder13: isUnder13 ?? this.isUnder13,
      parentEmail: parentEmail ?? this.parentEmail,
      applicationStatus:
      applicationStatus ?? this.applicationStatus,
      createdAt: createdAt ?? this.createdAt,
      tutorId: clearTutorId ? null : (tutorId ?? this.tutorId),
    );
  }
}