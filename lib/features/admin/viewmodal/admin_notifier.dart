
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutor_tech/features/admin/model/admin_state.dart';
import 'package:tutor_tech/features/admin/provider/admin_provider.dart';
import 'package:tutor_tech/features/admin/viewmodal/admin_repository.dart';

class AdminNotifier extends Notifier<AdminState> {
  late final AdminRepository adminRepo;

  @override
  AdminState build() {
    adminRepo = ref.read(adminRepoProvider);
    return AdminState();
  }

  Future<void> loadAllFilteredTutors(String subject) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);
      final filteredTutor = await adminRepo.getFilteredTutor(subject);
      state = state.copyWith(isLoading: false, filteredTutors: filteredTutor);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        clearError: false,
      );
    }
  }
  Future<void> loadAllFilteredStudent(String tutorId)async{
    try{
      state = state.copyWith(isLoading: true,clearError: true);
      final filteredStd = await adminRepo.getFilteredStudent(tutorId);
      state = state.copyWith(isLoading: false,filteredStudents: filteredStd);
    }catch(e){
      state = state.copyWith(isLoading: false,clearError: false,errorMessage: e.toString());
    }
  }
}
