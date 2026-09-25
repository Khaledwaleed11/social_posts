import '../repositories/comments_repository.dart';

class DeleteCommentUseCase {
  final CommentsRepository repository;

  DeleteCommentUseCase(this.repository);

  Future<void> call({required String postId, required String commentId}) {
    return repository.deleteComment(postId: postId, commentId: commentId);
  }
}
