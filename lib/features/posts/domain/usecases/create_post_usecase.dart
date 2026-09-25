import 'dart:io';

import '../entities/post_entity.dart';
import '../repositories/posts_repository.dart';

class CreatePostUseCase {
  final PostsRepository repository;

  CreatePostUseCase(this.repository);

  Future<PostEntity> call({required String content, File? image}) {
    return repository.createPost(content: content, image: image);
  }
}
