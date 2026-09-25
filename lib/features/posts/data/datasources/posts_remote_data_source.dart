import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/storage/image_storage_data_source.dart';
import '../models/post_model.dart';

abstract class PostsRemoteDataSource {
  Future<List<PostModel>> getPosts();

  Future<PostModel> createPost({required String content, File? image});

  Future<void> toggleLike({required String postId, required String userId});

  Future<void> deletePost({required String postId});
}

class PostsRemoteDataSourceImpl implements PostsRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;
  final ImageStorageDataSource imageStorageDataSource;

  PostsRemoteDataSourceImpl({
    required this.firestore,
    required this.firebaseAuth,
    required this.imageStorageDataSource,
  });

  CollectionReference<Map<String, dynamic>> get _postsCollection =>
      firestore.collection('posts');

  @override
  Future<List<PostModel>> getPosts() async {
    final snapshot = await _postsCollection
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((document) {
      return PostModel.fromMap(document.data(), documentId: document.id);
    }).toList();
  }

  @override
  Future<PostModel> createPost({required String content, File? image}) async {
    final currentUser = firebaseAuth.currentUser;

    if (currentUser == null) {
      throw Exception('User is not logged in.');
    }

    final userDocument = await firestore
        .collection('users')
        .doc(currentUser.uid)
        .get();

    final userData = userDocument.data();

    final document = _postsCollection.doc();

    String? imageUrl;

    if (image != null) {
      imageUrl = await imageStorageDataSource.uploadPostImage(
        postId: document.id,
        image: image,
      );
    }

    final post = PostModel(
      id: document.id,
      userId: currentUser.uid,
      userName: userData?['name'] ?? 'User',
      userImage: userData?['imageUrl'],
      content: content,
      imageUrl: imageUrl,
      createdAt: DateTime.now(),
      likedBy: const [],
      commentsCount: 0,
    );

    await document.set(post.toMap());

    return post;
  }

  @override
  Future<void> toggleLike({
    required String postId,
    required String userId,
  }) async {
    final postReference = _postsCollection.doc(postId);

    final document = await postReference.get();

    if (!document.exists) {
      throw Exception('Post not found.');
    }

    final data = document.data()!;

    final likedBy = List<String>.from(data['likedBy'] ?? []);

    if (likedBy.contains(userId)) {
      likedBy.remove(userId);
    } else {
      likedBy.add(userId);
    }

    await postReference.update({'likedBy': likedBy});
  }

  @override
  Future<void> deletePost({required String postId}) async {
    await _postsCollection.doc(postId).delete();
  }
}
