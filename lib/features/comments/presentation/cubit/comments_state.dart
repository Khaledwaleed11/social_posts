import 'package:equatable/equatable.dart';

import '../../domain/entities/comment_entity.dart';

abstract class CommentsState extends Equatable {
  const CommentsState();

  @override
  List<Object?> get props => [];
}

class CommentsInitial extends CommentsState {}

class CommentsLoading extends CommentsState {}

class CommentsLoaded extends CommentsState {
  final List<CommentEntity> comments;

  const CommentsLoaded(this.comments);

  @override
  List<Object?> get props => [comments];
}

class CommentsError extends CommentsState {
  final String message;

  const CommentsError(this.message);

  @override
  List<Object?> get props => [message];
}

class CommentAdding extends CommentsState {
  final List<CommentEntity> comments;

  const CommentAdding(this.comments);

  @override
  List<Object?> get props => [comments];
}

class CommentDeleting extends CommentsState {
  final List<CommentEntity> comments;

  const CommentDeleting(this.comments);

  @override
  List<Object?> get props => [comments];
}
