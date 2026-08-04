import '../../../core/constants/app_colors.dart';
import 'package:flutter/material.dart';
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
enum SubjectStage {
  primary,
  elevenPlus,
  gcse,
  aLevel,
  btec,
}
extension SubjectStageExtension on SubjectStage {
  Color get color {
    switch (this) {
      case SubjectStage.primary:
        return AppColors.primaryStage;
      case SubjectStage.elevenPlus:
        return AppColors.elevenPlus;
      case SubjectStage.gcse:
        return AppColors.gcseColor;
      case SubjectStage.aLevel:
        return AppColors.aLevelColor;
      case SubjectStage.btec:
        return AppColors.btecColor;
    }
  }

  String get displayName {
    switch (this) {
      case SubjectStage.primary:
        return 'Primary';
      case SubjectStage.elevenPlus:
        return '11+';
      case SubjectStage.gcse:
        return 'GCSE';
      case SubjectStage.aLevel:
        return 'A-Level';
      case SubjectStage.btec:
        return 'BTEC';
    }
  }
}
class StudentModel {
  final String id;
  final String userId;
  final String fullName;
  final String email;
  final DateTime? dateOfBirth;
  final AgeGroup ageGroup;
  final List<String> selectedSubjects;
  final GroupSize preferredGroupSize;
  final String? assignedTutorId;
  final String? parentId;
  final CommunicationPref communicationPreference;
  final bool recordingConsentGiven;
  final DateTime? recordingConsentTimestamp;
  final bool isUnder13;
  final String? profileImageUrl;
  final DateTime createdAt;

  const StudentModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.email,
    this.dateOfBirth,
    required this.ageGroup,
    required this.selectedSubjects,
    required this.preferredGroupSize,
    this.assignedTutorId,
    this.parentId,
    this.communicationPreference = CommunicationPref.both,
    this.recordingConsentGiven = false,
    this.recordingConsentTimestamp,
    required this.isUnder13,
    this.profileImageUrl,
    required this.createdAt,
  });

  StudentModel copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? email,
    DateTime? dateOfBirth,
    AgeGroup? ageGroup,
    List<String>? selectedSubjects,
    GroupSize? preferredGroupSize,
    String? assignedTutorId,
    String? parentId,
    CommunicationPref? communicationPreference,
    bool? recordingConsentGiven,
    DateTime? recordingConsentTimestamp,
    bool? isUnder13,
    String? profileImageUrl,
    DateTime? createdAt,
  }) {
    return StudentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      ageGroup: ageGroup ?? this.ageGroup,
      selectedSubjects: selectedSubjects ?? this.selectedSubjects,
      preferredGroupSize: preferredGroupSize ?? this.preferredGroupSize,
      assignedTutorId: assignedTutorId ?? this.assignedTutorId,
      parentId: parentId ?? this.parentId,
      communicationPreference: communicationPreference ?? this.communicationPreference,
      recordingConsentGiven: recordingConsentGiven ?? this.recordingConsentGiven,
      recordingConsentTimestamp: recordingConsentTimestamp ?? this.recordingConsentTimestamp,
      isUnder13: isUnder13 ?? this.isUnder13,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'full_name': fullName,
      'email': email,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'age_group': ageGroup.name,
      'selected_subjects': selectedSubjects,
      'preferred_group_size': preferredGroupSize.name,
      'assigned_tutor_id': assignedTutorId,
      'parent_id': parentId,
      'communication_pref': communicationPreference.name,
      'recording_consent_given': recordingConsentGiven,
      'recording_consent_timestamp': recordingConsentTimestamp?.toIso8601String(),
      'is_under_13': isUnder13,
      'profile_image_url': profileImageUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? json['userId'] as String? ?? '',
      fullName: json['full_name'] as String? ?? json['fullName'] as String? ?? '',
      email: json['email'] as String,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'] as String)
          : null,
      ageGroup: AgeGroup.values.firstWhere(
        (e) => e.name == json['age_group'] || e.name == json['ageGroup'],
        orElse: () => AgeGroup.gcse,
      ),
      selectedSubjects: List<String>.from(json['selected_subjects'] ?? json['selectedSubjects'] ?? []),
      preferredGroupSize: GroupSize.values.firstWhere(
        (e) => e.name == json['preferred_group_size'] || e.name == json['preferredGroupSize'],
        orElse: () => GroupSize.oneToOne,
      ),
      assignedTutorId: json['assigned_tutor_id'] as String? ?? json['assignedTutorId'] as String?,
      parentId: json['parent_id'] as String? ?? json['parentId'] as String?,
      communicationPreference: CommunicationPref.values.firstWhere(
        (e) => e.name == json['communication_pref'] || e.name == json['communicationPreference'],
        orElse: () => CommunicationPref.both,
      ),
      recordingConsentGiven: json['recording_consent_given'] as bool? ?? json['recordingConsentGiven'] as bool? ?? false,
      recordingConsentTimestamp: json['recording_consent_timestamp'] != null
          ? DateTime.parse(json['recording_consent_timestamp'] as String)
          : null,
      isUnder13: json['is_under_13'] as bool? ?? json['isUnder13'] as bool? ?? false,
      profileImageUrl: json['profile_image_url'] as String? ?? json['profileImageUrl'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }
}
