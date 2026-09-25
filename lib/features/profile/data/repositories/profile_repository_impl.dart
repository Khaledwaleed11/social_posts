import 'dart:io';

import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ProfileEntity> getProfile() {
    return remoteDataSource.getProfile();
  }

  @override
  Future<ProfileEntity> updateProfile({required String name}) {
    return remoteDataSource.updateProfile(name: name);
  }

  @override
  Future<ProfileEntity> updateProfileImage({required File image}) {
    return remoteDataSource.updateProfileImage(image: image);
  }
}
