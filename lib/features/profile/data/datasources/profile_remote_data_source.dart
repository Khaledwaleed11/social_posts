import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/storage/image_storage_data_source.dart';
import '../models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile();

  Future<ProfileModel> updateProfile({required String name});

  Future<ProfileModel> updateProfileImage({required File image});
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;
  final ImageStorageDataSource imageStorageDataSource;

  ProfileRemoteDataSourceImpl({
    required this.firestore,
    required this.firebaseAuth,
    required this.imageStorageDataSource,
  });

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get _postsCollection =>
      firestore.collection('posts');

  @override
  Future<ProfileModel> getProfile() async {
    final currentUser = firebaseAuth.currentUser;

    if (currentUser == null) {
      throw Exception('User is not logged in.');
    }

    final userDocument = await _usersCollection.doc(currentUser.uid).get();

    if (!userDocument.exists) {
      throw Exception('User profile not found.');
    }

    final userData = userDocument.data()!;

    final postsSnapshot = await _postsCollection
        .where('userId', isEqualTo: currentUser.uid)
        .get();

    return ProfileModel.fromMap(
      userData,
      postsCount: postsSnapshot.docs.length,
    );
  }

  @override
  Future<ProfileModel> updateProfile({required String name}) async {
    final currentUser = firebaseAuth.currentUser;

    if (currentUser == null) {
      throw Exception('User is not logged in.');
    }

    await _usersCollection.doc(currentUser.uid).update({'name': name});

    await currentUser.updateDisplayName(name);

    return getProfile();
  }

  @override
  Future<ProfileModel> updateProfileImage({required File image}) async {
    final currentUser = firebaseAuth.currentUser;

    if (currentUser == null) {
      throw Exception('User is not logged in.');
    }

    final imageUrl = await imageStorageDataSource.uploadProfileImage(
      userId: currentUser.uid,
      image: image,
    );

    await _usersCollection.doc(currentUser.uid).update({'imageUrl': imageUrl});

    await currentUser.updatePhotoURL(imageUrl);

    return getProfile();
  }
}
