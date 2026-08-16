import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tutor_tech/features/admin/data/admin_repository_impl.dart';
import 'package:tutor_tech/features/admin/model/admin_state.dart';
import 'package:tutor_tech/features/admin/viewmodal/admin_notifier.dart';
import 'package:tutor_tech/features/admin/viewmodal/admin_repository.dart';
import 'package:tutor_tech/features/student/provider/provider.dart';
import 'package:tutor_tech/features/tutor/provider/tutor_dashboardScreen_provider.dart';

final adminRepoProvider = Provider<AdminRepository>((ref) {
  return AdminRepositoryImpl(
    ref.read(tutorRepoProvider),
    ref.read(studentRepoProvider),
  );
});
final adminProvider = NotifierProvider<AdminNotifier, AdminState>(
  AdminNotifier.new,
);
