import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutor_tech/core/provider/third_party_provider.dart';
import 'package:tutor_tech/features/groups/model/group_model.dart';
import 'package:tutor_tech/features/groups/repo/repository_impl.dart';
import 'package:tutor_tech/features/groups/viewmodal/groupBytutorId_notifier.dart';
import 'package:tutor_tech/features/groups/viewmodal/studentGroup_notifier.dart';


final studentGroupRepo = Provider((ref) {
  return StudentGroupRepositoryImpl(ref.read(fireStoreProvider));
});
final groupByTutorIdProvider =
    AutoDisposeAsyncNotifierProviderFamily<
      GroupByTutorIdNotifier,
      List<StudentGroupModel>,
      String
    >(GroupByTutorIdNotifier.new);
final groupByStudentId =
AutoDisposeAsyncNotifierProviderFamily<
    StudentGroupNotifier,
    List<StudentGroupModel>,
    String
>(StudentGroupNotifier.new);
