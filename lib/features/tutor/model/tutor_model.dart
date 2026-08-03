enum TutorApplicationStatus {
  pending,
  underReview,
  approved,
  rejected,
}

class TutorModel {
  final String id;
  final String userId;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final List<String> availability;
  final String education;
  final String teachingExperience;
  final List<String> subjectExpertise;
  final List<String> teachingLevels;
  final String? cvLink;
  final String? coverLetter;
  final TutorApplicationStatus applicationStatus;
  final bool dbsVerified;
  final String? profileImageUrl;
  final double rating;
  final int totalSessions;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime? approvedAt;
  final String? approvedBy;

  const TutorModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    required this.availability,
    required this.education,
    required this.teachingExperience,
    required this.subjectExpertise,
    required this.teachingLevels,
    this.cvLink,
    this.coverLetter,
    this.applicationStatus = TutorApplicationStatus.pending,
    this.dbsVerified = false,
    this.profileImageUrl,
    this.rating = 0.0,
    this.totalSessions = 0,
    this.isAvailable = true,
    required this.createdAt,
    this.approvedAt,
    this.approvedBy,
  });

  TutorModel copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? email,
    String? phoneNumber,
    List<String>? availability,
    String? education,
    String? teachingExperience,
    List<String>? subjectExpertise,
    List<String>? teachingLevels,
    String? cvLink,
    String? coverLetter,
    TutorApplicationStatus? applicationStatus,
    bool? dbsVerified,
    String? profileImageUrl,
    double? rating,
    int? totalSessions,
    bool? isAvailable,
    DateTime? createdAt,
    DateTime? approvedAt,
    String? approvedBy,
  }) {
    return TutorModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      availability: availability ?? this.availability,
      education: education ?? this.education,
      teachingExperience: teachingExperience ?? this.teachingExperience,
      subjectExpertise: subjectExpertise ?? this.subjectExpertise,
      teachingLevels: teachingLevels ?? this.teachingLevels,
      cvLink: cvLink ?? this.cvLink,
      coverLetter: coverLetter ?? this.coverLetter,
      applicationStatus: applicationStatus ?? this.applicationStatus,
      dbsVerified: dbsVerified ?? this.dbsVerified,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      rating: rating ?? this.rating,
      totalSessions: totalSessions ?? this.totalSessions,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      approvedAt: approvedAt ?? this.approvedAt,
      approvedBy: approvedBy ?? this.approvedBy,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'availability': availability,
      'education': education,
      'teaching_experience': teachingExperience,
      'subject_expertise': subjectExpertise,
      'teaching_levels': teachingLevels,
      'cv_link': cvLink,
      'cover_letter': coverLetter,
      'application_status': applicationStatus.name,
      'dbs_verified': dbsVerified,
      'profile_image_url': profileImageUrl,
      'rating': rating,
      'total_sessions': totalSessions,
      'is_available': isAvailable,
      'created_at': createdAt.toIso8601String(),
      'approved_at': approvedAt?.toIso8601String(),
      'approved_by': approvedBy,
    };
  }

  factory TutorModel.fromJson(Map<String, dynamic> json) {
    return TutorModel(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? json['userId'] as String? ?? '',
      fullName: json['full_name'] as String? ?? json['fullName'] as String? ?? '',
      email: json['email'] as String,
      phoneNumber: json['phone_number'] as String? ?? json['phoneNumber'] as String?,
      availability: List<String>.from(json['availability'] ?? []),
      education: json['education'] as String? ?? '',
      teachingExperience: json['teaching_experience'] as String? ?? json['teachingExperience'] as String? ?? '',
      subjectExpertise: List<String>.from(json['subject_expertise'] ?? json['subjectExpertise'] ?? []),
      teachingLevels: List<String>.from(json['teaching_levels'] ?? json['teachingLevels'] ?? []),
      cvLink: json['cv_link'] as String? ?? json['cvLink'] as String?,
      coverLetter: json['cover_letter'] as String? ?? json['coverLetter'] as String?,
      applicationStatus: TutorApplicationStatus.values.firstWhere(
        (s) => s.name == json['application_status'] || s.name == json['applicationStatus'],
        orElse: () => TutorApplicationStatus.pending,
      ),
      dbsVerified: json['dbs_verified'] as bool? ?? json['dbsVerified'] as bool? ?? false,
      profileImageUrl: json['profile_image_url'] as String? ?? json['profileImageUrl'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalSessions: json['total_sessions'] as int? ?? json['totalSessions'] as int? ?? 0,
      isAvailable: json['is_available'] as bool? ?? json['isAvailable'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      approvedAt: json['approved_at'] != null
          ? DateTime.parse(json['approved_at'] as String)
          : null,
      approvedBy: json['approved_by'] as String? ?? json['approvedBy'] as String?,
    );
  }
}
