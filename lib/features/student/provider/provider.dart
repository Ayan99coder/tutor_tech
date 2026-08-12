import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutor_tech/core/provider/provider.dart';
import 'package:tutor_tech/features/student/data/student_repository_impl.dart';
import 'package:tutor_tech/features/student/model/student_dashboard_state.dart';

import 'package:tutor_tech/features/student/viewmodal/student_dashboard_notifier.dart';
import 'package:tutor_tech/features/tutor/data/tutor_repository.impl.dart';

import '../model/student_repository.dart';

final studentRepoProvider = Provider<StudentRepository>((ref) {
  return StudentRepositoryImpl(ref.read(firebaseFirestoreProvider));
});
final studentProvider =
    NotifierProviderFamily<
      StudentDashboardNotifier,
      StudentDashboardState,
      String
    >(StudentDashboardNotifier.new);
