import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/post_entity.dart';
import '../../domain/usecases/create_post_usecase.dart';
import '../../domain/usecases/delete_post_usecase.dart';
import '../../domain/usecases/get_posts_usecase.dart';
import '../../domain/usecases/toggle_like_usecase.dart';
import 'posts_state.dart';

class PostsCubit extends Cubit<PostsState> {
  final GetPostsUseCase getPostsUseCase;
  final CreatePostUseCase createPostUseCase;
  final ToggleLikeUseCase toggleLikeUseCase;
  final DeletePostUseCase deletePostUseCase;

  PostsCubit({
    required this.getPostsUseCase,
    required this.createPostUseCase,
    required this.toggleLikeUseCase,
    required this.deletePostUseCase,
  }) : super(PostsInitial());

  // ============================================================
  // Get Posts
  // ============================================================

  Future<void> getPosts() async {
    emit(PostsLoading());

    try {
      final posts = await getPostsUseCase();

      emit(PostsLoaded(posts));
    } catch (e) {
      emit(PostsError('Failed to load posts.'));
    }
  }

  // ============================================================
  // Create Post
  // ============================================================

  Future<void> createPost(String content, {File? image}) async {
    try {
      await createPostUseCase(content: content, image: image);

      await getPosts();
    } catch (e) {
      emit(PostsError('Failed to create post.'));
    }
  }

  // ============================================================
  // Toggle Like - Optimistic Update
  // ============================================================

  Future<void> toggleLike({
    required String postId,
    required String userId,
  }) async {
    final currentState = state;

    // We can only update the UI optimistically
    // when posts are already loaded.
    if (currentState is! PostsLoaded) {
      return;
    }

    final currentPosts = List<PostEntity>.from(currentState.posts);

    final postIndex = currentPosts.indexWhere((post) => post.id == postId);

    if (postIndex == -1) {
      return;
    }

    final oldPost = currentPosts[postIndex];

    final oldLikedBy = List<String>.from(oldPost.likedBy);

    final newLikedBy = List<String>.from(oldPost.likedBy);

    final isCurrentlyLiked = newLikedBy.contains(userId);

    if (isCurrentlyLiked) {
      newLikedBy.remove(userId);
    } else {
      newLikedBy.add(userId);
    }

    final updatedPost = PostEntity(
      id: oldPost.id,
      userId: oldPost.userId,
      userName: oldPost.userName,
      userImage: oldPost.userImage,
      content: oldPost.content,
      imageUrl: oldPost.imageUrl,
      createdAt: oldPost.createdAt,
      likedBy: newLikedBy,
      commentsCount: oldPost.commentsCount,
    );

    currentPosts[postIndex] = updatedPost;

    // Update UI immediately.
    emit(PostsLoaded(currentPosts));

    try {
      // Update Firebase in the background.
      await toggleLikeUseCase(postId: postId, userId: userId);
    } catch (e) {
      // Firebase failed.
      // Roll back the optimistic update.
      final latestState = state;

      if (latestState is PostsLoaded) {
        final rollbackPosts = List<PostEntity>.from(latestState.posts);

        final latestPostIndex = rollbackPosts.indexWhere(
          (post) => post.id == postId,
        );

        if (latestPostIndex != -1) {
          final latestPost = rollbackPosts[latestPostIndex];

          rollbackPosts[latestPostIndex] = PostEntity(
            id: latestPost.id,
            userId: latestPost.userId,
            userName: latestPost.userName,
            userImage: latestPost.userImage,
            content: latestPost.content,
            imageUrl: latestPost.imageUrl,
            createdAt: latestPost.createdAt,
            likedBy: oldLikedBy,
            commentsCount: latestPost.commentsCount,
          );

          emit(PostsLoaded(rollbackPosts));
        }
      }

      emit(PostsError('Failed to update like.'));
    }
  }

  // ============================================================
  // Update Comments Count Locally
  // ============================================================

  void updateCommentsCount({required String postId, required int delta}) {
    final currentState = state;

    if (currentState is! PostsLoaded) {
      return;
    }

    final posts = List<PostEntity>.from(currentState.posts);

    final postIndex = posts.indexWhere((post) => post.id == postId);

    if (postIndex == -1) {
      return;
    }

    final post = posts[postIndex];

    final newCommentsCount = post.commentsCount + delta < 0
        ? 0
        : post.commentsCount + delta;

    posts[postIndex] = PostEntity(
      id: post.id,
      userId: post.userId,
      userName: post.userName,
      userImage: post.userImage,
      content: post.content,
      imageUrl: post.imageUrl,
      createdAt: post.createdAt,
      likedBy: post.likedBy,
      commentsCount: newCommentsCount,
    );

    emit(PostsLoaded(posts));
  }

  // ============================================================
  // Delete Post
  // ============================================================

  Future<void> deletePost(String postId) async {
    try {
      await deletePostUseCase(postId: postId);

      await getPosts();
    } catch (e) {
      emit(PostsError('Failed to delete post.'));
    }
  }
}
