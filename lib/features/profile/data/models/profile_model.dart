import '../../domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.id,
    required super.name,
    required super.email,
    super.imageUrl,
    required super.postsCount,
  });

  factory ProfileModel.fromMap(
    Map<String, dynamic> map, {
    required int postsCount,
  }) {
    return ProfileModel(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      imageUrl: map['imageUrl'] as String?,
      postsCount: postsCount,
    );
  }

  factory ProfileModel.fromEntity(ProfileEntity entity) {
    return ProfileModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      imageUrl: entity.imageUrl,
      postsCount: entity.postsCount,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'email': email, 'imageUrl': imageUrl};
  }
}
