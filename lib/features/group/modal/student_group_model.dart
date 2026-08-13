class StudentGroupModel {
  final String? id;
  final String tutorId;
  final String groupName;
  final String? description;
  final List<String> studentIds;
  final List<String> studentNames;
  final DateTime createdAt;

  const StudentGroupModel({
     this.id,
    required this.tutorId,
    required this.groupName,
    this.description,
    required this.studentIds,
    required this.studentNames,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tutor_id': tutorId,
      'group_name': groupName,
      'description': description,
      'student_ids': studentIds,
      'student_names': studentNames,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory StudentGroupModel.fromJson(
    Map<String, dynamic> json,
    String documentId,
  ) {
    DateTime parsedDate = DateTime.now();
    final rawCreated = json['created_at'] ?? json['createdAt'];
    if (rawCreated != null) {
      if (rawCreated is String) {
        parsedDate = DateTime.tryParse(rawCreated) ?? DateTime.now();
      } else if (rawCreated.runtimeType.toString().contains('Timestamp')) {
        try {
          parsedDate = (rawCreated as dynamic).toDate();
        } catch (_) {}
      }
    }

    final rawName =
        json['group_name'] as String? ??
        json['groupName'] as String? ??
        json['name'] as String? ??
        json['title'] as String?;
    final gName = (rawName != null && rawName.trim().isNotEmpty)
        ? rawName.trim()
        : 'Student Group';

    return StudentGroupModel(
      id: documentId,
      tutorId: json['tutor_id'] as String? ?? json['tutorId'] as String? ?? '',
      groupName: gName,
      description: json['description'] as String?,
      studentIds: List<String>.from(
        json['student_ids'] ?? json['studentIds'] ?? [],
      ),
      studentNames: List<String>.from(
        json['student_names'] ?? json['studentNames'] ?? [],
      ),
      createdAt: parsedDate,
    );
  }
}

