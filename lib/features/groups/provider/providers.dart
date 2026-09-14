import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutor_tech/core/provider/third_party_provider.dart';
import 'package:tutor_tech/features/groups/repo/repository_impl.dart';

final studentGroupRepo = Provider((ref) {
  return StudentGroupRepositoryImpl(ref.read(fireStoreProvider));
});
