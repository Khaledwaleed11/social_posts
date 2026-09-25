import 'dart:io';

import '../../domain/entities/post_entity.dart';
import '../../domain/repositories/posts_repository.dart';
import '../datasources/posts_remote_data_source.dart';

class PostsRepositoryImpl implements PostsRepository {
  final PostsRemoteDataSource remoteDataSource;

  PostsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<PostEntity>> getPosts() {
    return remoteDataSource.getPosts();
  }

  @override
  Future<PostEntity> createPost({required String content, File? image}) {
    return remoteDataSource.createPost(content: content, image: image);
  }

  @override
  Future<void> toggleLike({required String postId, required String userId}) {
    return remoteDataSource.toggleLike(postId: postId, userId: userId);
  }

  @override
  Future<void> deletePost({required String postId}) {
    return remoteDataSource.deletePost(postId: postId);
  }
}
