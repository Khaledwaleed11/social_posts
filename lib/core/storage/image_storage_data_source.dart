import 'dart:io';

abstract class ImageStorageDataSource {
  Future<String> uploadProfileImage({
    required String userId,
    required File image,
  });

  Future<String> uploadPostImage({required String postId, required File image});
}
