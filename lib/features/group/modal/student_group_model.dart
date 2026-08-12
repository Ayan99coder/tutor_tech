class StudentGroupModel {
  final String id;
  final String tutorId;
  final String groupName;
  final List<String> studentIds;
  final List<String> studentNames;
  final DateTime createdAt;

  const StudentGroupModel({
    required this.id,
    required this.tutorId,
    required this.groupName,
    required this.studentIds,
    required this.studentNames,
    required this.createdAt,
  });

  factory StudentGroupModel.fromJson(
    Map<String, dynamic> json,
    String documentId,
  ) {
    return StudentGroupModel(
      id: documentId,
      tutorId: json['tutor_id'] as String? ?? json['tutorId'] as String? ?? '',
      groupName:
          json['group_name'] as String? ?? json['groupName'] as String? ?? '',
      studentIds: List<String>.from(
        json['student_ids'] ?? json['studentIds'] ?? [],
      ),
      studentNames: List<String>.from(
        json['student_names'] ?? json['studentNames'] ?? [],
      ),
      createdAt: _parseDateTime(json['created_at'] ?? json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tutor_id': tutorId,
      'group_name': groupName,
      'student_ids': studentIds,
      'student_names': studentNames,
      'created_at': createdAt.toIso8601String(),
    };
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }

    return DateTime.now();
  }
}

class StudentGroupStudentModel {
  final String id;
  final String name;
  final String email;

  const StudentGroupStudentModel({
    required this.id,
    required this.name,
    required this.email,
  });
}