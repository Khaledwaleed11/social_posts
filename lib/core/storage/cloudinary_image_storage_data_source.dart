import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'image_storage_data_source.dart';

class CloudinaryImageStorageDataSource implements ImageStorageDataSource {
  static const String _cloudName = 'ypm25lyf';
  static const String _uploadPreset = 'social_posts_unsigned';

  @override
  Future<String> uploadProfileImage({
    required String userId,
    required File image,
  }) async {
    return _uploadImage(image: image, folder: 'social_posts/profile_images');
  }

  @override
  Future<String> uploadPostImage({
    required String postId,
    required File image,
  }) async {
    return _uploadImage(image: image, folder: 'social_posts/post_images');
  }

  Future<String> _uploadImage({
    required File image,
    required String folder,
  }) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
    );

    final request = http.MultipartRequest('POST', uri);

    request.fields['upload_preset'] = _uploadPreset;
    request.fields['folder'] = folder;

    request.files.add(await http.MultipartFile.fromPath('file', image.path));

    final response = await request.send();

    final responseBody = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      throw Exception(
        'Cloudinary upload failed: '
        '${response.statusCode} - $responseBody',
      );
    }

    final data = jsonDecode(responseBody) as Map<String, dynamic>;

    final secureUrl = data['secure_url'] as String?;

    if (secureUrl == null || secureUrl.isEmpty) {
      throw Exception('Cloudinary did not return a secure URL.');
    }

    return secureUrl;
  }
}
