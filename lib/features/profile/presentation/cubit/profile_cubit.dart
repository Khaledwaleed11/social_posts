import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_image_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final UpdateProfileImageUseCase updateProfileImageUseCase;

  ProfileCubit({
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
    required this.updateProfileImageUseCase,
  }) : super(ProfileInitial());

  Future<void> getProfile() async {
    emit(ProfileLoading());

    try {
      final profile = await getProfileUseCase();

      emit(ProfileLoaded(profile));
    } catch (e) {
      emit(const ProfileError('Failed to load profile.'));
    }
  }

  Future<void> updateProfile({required String name}) async {
    final currentState = state;

    if (currentState is! ProfileLoaded && currentState is! ProfileUpdated) {
      return;
    }

    final currentProfile = currentState is ProfileLoaded
        ? currentState.profile
        : (currentState as ProfileUpdated).profile;

    emit(ProfileUpdating(currentProfile));

    try {
      final profile = await updateProfileUseCase(name: name);

      emit(ProfileUpdated(profile));
    } catch (e) {
      emit(const ProfileError('Failed to update profile.'));

      emit(ProfileLoaded(currentProfile));
    }
  }

  Future<void> updateProfileImage({required File image}) async {
    final currentState = state;

    if (currentState is! ProfileLoaded && currentState is! ProfileUpdated) {
      return;
    }

    final currentProfile = currentState is ProfileLoaded
        ? currentState.profile
        : (currentState as ProfileUpdated).profile;

    emit(ProfileUpdating(currentProfile));

    try {
      final profile = await updateProfileImageUseCase(image: image);

      emit(ProfileUpdated(profile));
    } catch (e) {
      debugPrint('PROFILE IMAGE UPDATE ERROR: $e');

      emit(
        const ProfileError(
          'Failed to update profile image.',
        ),
      );

      emit(ProfileLoaded(currentProfile));
    }
  }
}
