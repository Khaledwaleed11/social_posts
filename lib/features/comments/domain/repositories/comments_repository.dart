import '../entities/comment_entity.dart';

abstract class CommentsRepository {
  Future<List<CommentEntity>> getComments({required String postId});

  Future<CommentEntity> addComment({
    required String postId,
    required String content,
  });

  Future<void> deleteComment({
    required String postId,
    required String commentId,
  });
}
