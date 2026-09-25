import 'package:equatable/equatable.dart';

class PostEntity extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String? userImage;
  final String content;
  final String? imageUrl;
  final DateTime createdAt;
  final List<String> likedBy;
  final int commentsCount;

  const PostEntity({
    required this.id,
    required this.userId,
    required this.userName,
    this.userImage,
    required this.content,
    this.imageUrl,
    required this.createdAt,
    required this.likedBy,
    this.commentsCount = 0,
  });

  int get likesCount => likedBy.length;

  @override
  List<Object?> get props => [
    id,
    userId,
    userName,
    userImage,
    content,
    imageUrl,
    createdAt,
    likedBy,
    commentsCount,
  ];
}
