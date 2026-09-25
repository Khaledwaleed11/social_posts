import '../../domain/entities/comment_entity.dart';
import '../../domain/repositories/comments_repository.dart';
import '../datasources/comments_remote_data_source.dart';

class CommentsRepositoryImpl implements CommentsRepository {
  final CommentsRemoteDataSource remoteDataSource;

  CommentsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<CommentEntity>> getComments({required String postId}) {
    return remoteDataSource.getComments(postId: postId);
  }

  @override
  Future<CommentEntity> addComment({
    required String postId,
    required String content,
  }) {
    return remoteDataSource.addComment(postId: postId, content: content);
  }

  @override
  Future<void> deleteComment({
    required String postId,
    required String commentId,
  }) {
    return remoteDataSource.deleteComment(postId: postId, commentId: commentId);
  }
}
