import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutor_tech/features/group/modal/student_group_state.dart';
import 'package:tutor_tech/features/group/provider/provider.dart';
import 'package:tutor_tech/features/group/viewmodal/student_group_repository.dart';

import '../modal/student_group_model.dart';

class StudentGroupNotifier
    extends AutoDisposeFamilyNotifier<StudentGroupState, String> {
  late StudentGroupRepository repo;
  late String ids;

  @override
  StudentGroupState build(String id) {
    ids = id;
    repo = ref.read(studentRepoProvider);
    return StudentGroupState();
  }

  Future<void> saveGroup(StudentGroupModel group) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      final savedGroup = await repo.saveGroup(group);

      state = state.copyWith(
        isLoading: false,
        groups: [savedGroup, ...state.groups],
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
  Future<void> getGroup()async{
    try{
      state = state.copyWith(isLoading: true,clearError: true);
      final getGroup = await repo.getGroups(ids);
      state = state.copyWith(isLoading: false,groups:getGroup);
    }catch(e){
      state = state.copyWith(isLoading : false,errorMessage: e.toString());
    }
  }
}

