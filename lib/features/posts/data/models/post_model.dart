import '../../domain/entities/post_entity.dart';

class PostModel extends PostEntity {
  const PostModel({
    required super.id,
    required super.userId,
    required super.userName,
    super.userImage,
    required super.content,
    super.imageUrl,
    required super.createdAt,
    required super.likedBy,
    super.commentsCount,
  });

  factory PostModel.fromMap(
    Map<String, dynamic> map, {
    required String documentId,
  }) {
    final timestamp = map['createdAt'];

    return PostModel(
      id: documentId,
      userId: map['userId'] as String? ?? '',
      userName: map['userName'] as String? ?? '',
      userImage: map['userImage'] as String?,
      content: map['content'] as String? ?? '',
      imageUrl: map['imageUrl'] as String?,
      createdAt: timestamp != null ? timestamp.toDate() : DateTime.now(),
      likedBy: List<String>.from(map['likedBy'] ?? []),
      commentsCount: map['commentsCount'] as int? ?? 0,
    );
  }

  factory PostModel.fromEntity(PostEntity entity) {
    return PostModel(
      id: entity.id,
      userId: entity.userId,
      userName: entity.userName,
      userImage: entity.userImage,
      content: entity.content,
      imageUrl: entity.imageUrl,
      createdAt: entity.createdAt,
      likedBy: entity.likedBy,
      commentsCount: entity.commentsCount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userImage': userImage,
      'content': content,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
      'likedBy': likedBy,
      'commentsCount': commentsCount,
    };
  }
}
