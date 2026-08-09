import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutor_tech/features/tutor/viewmodal/tutor_dashboard_state.dart';

import '../provider/tutor_dashboardScreen_provider.dart';

class TutorDashboardViewmodal
    extends AutoDisposeFamilyNotifier<TutorDashboardState, String> {
  @override
  TutorDashboardState build(String tutorId) {
    final tutorRepo = ref.read(tutorRepoProvider);
    return const TutorDashboardState();
  }
}
