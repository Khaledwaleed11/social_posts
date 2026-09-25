import 'dart:io';

import '../entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<ProfileEntity> getProfile();

  Future<ProfileEntity> updateProfile({required String name});

  Future<ProfileEntity> updateProfileImage({required File image});
}
