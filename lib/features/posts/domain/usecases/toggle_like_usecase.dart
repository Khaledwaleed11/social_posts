import '../repositories/posts_repository.dart';

class ToggleLikeUseCase {
  final PostsRepository repository;

  ToggleLikeUseCase(this.repository);

  Future<void> call({
    required String postId,
    required String userId,
  }) {
    return repository.toggleLike(
      postId: postId,
      userId: userId,
    );
  }
}