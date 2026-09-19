import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutor_tech/features/groups/model/group_model.dart';
import 'package:tutor_tech/features/groups/provider/providers.dart';

class GroupByTutorIdNotifier
    extends AutoDisposeFamilyAsyncNotifier<List<StudentGroupModel>, String> {
  @override
  Future<List<StudentGroupModel>> build(String arg) {
    ref.onCancel(() {});

    ref.onResume(() {});

    ref.onDispose(() {});

    final repo = ref.read(studentGroupRepo);

    return repo.groupsByTutorId(arg);
  }
}
