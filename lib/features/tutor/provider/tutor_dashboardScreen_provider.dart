import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutor_tech/features/tutor/data/tutor_repository.impl.dart';
import 'package:tutor_tech/features/tutor/model/tutor_repository.dart';
import 'package:tutor_tech/features/tutor/viewmodal/tutor_dashboard_state.dart';
import 'package:tutor_tech/features/tutor/viewmodal/tutor_dashboard_viewmodal.dart';

final tutorDashboardProvider = NotifierProvider.autoDispose
    .family<TutorDashboardViewmodal, TutorDashboardState, String>(
      TutorDashboardViewmodal.new,
    );
final tutorRepoProvider = Provider<TutorRepository>((ref) {
  return TutorRepositoryImpl();
});
