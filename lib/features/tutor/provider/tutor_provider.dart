import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutor_tech/core/provider/third_party_provider.dart';
import 'package:tutor_tech/features/tutor/repository/repository_impl.dart';
import 'package:tutor_tech/features/tutor/repository/repostiory.dart';
import 'package:tutor_tech/features/tutor/viewmodal/tutor_notifier.dart';
import 'package:tutor_tech/features/tutor/viewmodal/tutor_state.dart';

final tutorRepoProvider = Provider<TutorRepository>((ref) {
  return TutorRepositoryImpl(ref.read(fireStoreProvider));
});
final tutorProvider = AsyncNotifierProviderFamily<TutorNotifier, TutorState, String?>(
  TutorNotifier.new,
);
