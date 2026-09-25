import '../entities/comment_entity.dart';
import '../repositories/comments_repository.dart';

class GetCommentsUseCase {
  final CommentsRepository repository;

  GetCommentsUseCase(this.repository);

  Future<List<CommentEntity>> call({required String postId}) {
    return repository.getComments(postId: postId);
  }
}
