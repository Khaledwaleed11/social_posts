import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/comment_entity.dart';

class CommentModel extends CommentEntity {
  const CommentModel({
    required super.id,
    required super.postId,
    required super.userId,
    required super.userName,
    super.userImage,
    required super.content,
    required super.createdAt,
  });

  factory CommentModel.fromMap(
    Map<String, dynamic> map, {
    required String documentId,
    required String postId,
  }) {
    final timestamp = map['createdAt'];

    return CommentModel(
      id: documentId,
      postId: postId,
      userId: map['userId'] as String? ?? '',
      userName: map['userName'] as String? ?? 'User',
      userImage: map['userImage'] as String?,
      content: map['content'] as String? ?? '',
      createdAt: timestamp is Timestamp ? timestamp.toDate() : DateTime.now(),
    );
  }

  factory CommentModel.fromEntity(CommentEntity entity) {
    return CommentModel(
      id: entity.id,
      postId: entity.postId,
      userId: entity.userId,
      userName: entity.userName,
      userImage: entity.userImage,
      content: entity.content,
      createdAt: entity.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'userId': userId,
      'userName': userName,
      'userImage': userImage,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
