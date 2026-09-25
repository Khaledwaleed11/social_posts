import 'dart:io';

import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileImageUseCase {
  final ProfileRepository repository;

  UpdateProfileImageUseCase(this.repository);

  Future<ProfileEntity> call({required File image}) {
    return repository.updateProfileImage(image: image);
  }
}
