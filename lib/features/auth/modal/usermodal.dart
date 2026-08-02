import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

enum UserRole {
  admin,
  tutor,
  student,
  parent,
}

enum ApplicationStatus {
  pending,
  approved,
  rejected,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.tutor:
        return 'Tutor';
      case UserRole.student:
        return 'Student';
      case UserRole.parent:
        return 'Parent';
    }
  }

  Color get color {
    switch (this) {
      case UserRole.admin:
        return AppColors.adminColor;
      case UserRole.tutor:
        return AppColors.tutorColor;
      case UserRole.student:
        return AppColors.studentColor;
      case UserRole.parent:
        return AppColors.parentColor;
    }
  }
}

class UserModel {
  final String id;
  final String email;
  final String fullName;
  final UserRole role;
  final String? profileImageUrl;
  final String? phoneNumber;
  final bool isActive;
  final bool isOnline;
  final DateTime createdAt;
  final ApplicationStatus applicationStatus;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.profileImageUrl,
    this.phoneNumber,
    this.isActive = true,
    this.isOnline = false,
    required this.createdAt,
   required this.applicationStatus,
  });

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    UserRole? role,
    String? profileImageUrl,
    String? phoneNumber,
    bool? isActive,
    bool? isOnline,
    DateTime? createdAt,
    ApplicationStatus? applicationStatus,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isActive: isActive ?? this.isActive,
      isOnline: isOnline ?? this.isOnline,
      createdAt: createdAt ?? this.createdAt,
      applicationStatus: applicationStatus ?? this.applicationStatus,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': role.name,
      'profile_image_url': profileImageUrl,
      'phone_number': phoneNumber,
      'is_active': isActive,
      'is_online': isOnline,
      'created_at': createdAt.toIso8601String(),
      'application_status': applicationStatus.name,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String? ??
          json['fullName'] as String? ??
          '',
      role: UserRole.values.firstWhere(
            (r) => r.name == json['role'],
        orElse: () => UserRole.student,
      ),
      profileImageUrl: json['profile_image_url'] as String? ??
          json['profileImageUrl'] as String?,
      phoneNumber: json['phone_number'] as String? ??
          json['phoneNumber'] as String?,
      isActive: json['is_active'] as bool? ??
          json['isActive'] as bool? ??
          true,
      isOnline: json['is_online'] as bool? ??
          json['isOnline'] as bool? ??
          false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      applicationStatus: ApplicationStatus.values.firstWhere(
            (status) => status.name == json['application_status'],
        orElse: () => ApplicationStatus.pending,
      ),
    );
  }
}