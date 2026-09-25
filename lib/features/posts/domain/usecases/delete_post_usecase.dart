import '../repositories/posts_repository.dart';

class DeletePostUseCase {
  final PostsRepository repository;

  DeletePostUseCase(this.repository);

  Future<void> call({
    required String postId,
  }) {
    return repository.deletePost(
      postId: postId,
    );
  }
}