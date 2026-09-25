import 'dart:io';

import '../entities/post_entity.dart';

abstract class PostsRepository {
  Future<List<PostEntity>> getPosts();

  Future<PostEntity> createPost({required String content, File? image});

  Future<void> toggleLike({required String postId, required String userId});

  Future<void> deletePost({required String postId});
}
