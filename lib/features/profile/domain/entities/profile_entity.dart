import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? imageUrl;
  final int postsCount;

  const ProfileEntity({
    required this.id,
    required this.name,
    required this.email,
    this.imageUrl,
    required this.postsCount,
  });

  @override
  List<Object?> get props => [id, name, email, imageUrl, postsCount];
}
