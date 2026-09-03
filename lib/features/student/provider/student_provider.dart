import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutor_tech/core/provider/third_party_provider.dart';
import 'package:tutor_tech/features/student/repostiory/repository.dart';
import 'package:tutor_tech/features/student/repostiory/repository_impl.dart';
import 'package:tutor_tech/features/student/viewmodal/student_notifier.dart';
import 'package:tutor_tech/features/student/viewmodal/student_state.dart';
import 'package:tutor_tech/features/tutor/provider/tutor_provider.dart';


final studentRepoProvider = Provider<StudentRepository>((ref) {
  return StudentRepositoryImpl(ref.read(fireStoreProvider),ref.read(tutorRepoProvider));
});
final studentProvider = AsyncNotifierProviderFamily<
    StudentNotifier,
    StudentState,
    String>(
  StudentNotifier.new,
);
