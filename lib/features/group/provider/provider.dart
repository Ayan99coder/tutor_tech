import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutor_tech/core/provider/provider.dart';
import 'package:tutor_tech/features/group/data/student_group_impl.dart';
import 'package:tutor_tech/features/group/viewmodal/student_group_repository.dart';

import '../modal/student_group_state.dart';
import '../viewmodal/student_group_notifier.dart';

final studentRepoProvider = Provider<StudentGroupRepository>((ref) {
  return StudentGroupRepositoryImpl(ref.read(firebaseFirestoreProvider));
});
final studentGroupProvider =
    NotifierProvider.autoDispose.family<StudentGroupNotifier, StudentGroupState, String>(
      StudentGroupNotifier.new,
    );
