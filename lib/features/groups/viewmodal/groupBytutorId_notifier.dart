import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutor_tech/features/groups/model/group_model.dart';
import 'package:tutor_tech/features/groups/provider/providers.dart';

class GroupbytutoridNotifier extends FamilyAsyncNotifier<List<StudentGroupModel>,String>{
   @override
  Future<List<StudentGroupModel>> build(String arg) {
   final repo = ref.read(studentGroupRepo);
   return repo.groupsByTutorId(arg);
  }
}