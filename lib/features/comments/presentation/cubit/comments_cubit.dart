import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/comment_entity.dart';
import '../../domain/usecases/add_comment_usecase.dart';
import '../../domain/usecases/delete_comment_usecase.dart';
import '../../domain/usecases/get_comments_usecase.dart';
import 'comments_state.dart';

class CommentsCubit extends Cubit<CommentsState> {
  final GetCommentsUseCase getCommentsUseCase;
  final AddCommentUseCase addCommentUseCase;
  final DeleteCommentUseCase deleteCommentUseCase;

  CommentsCubit({
    required this.getCommentsUseCase,
    required this.addCommentUseCase,
    required this.deleteCommentUseCase,
  }) : super(CommentsInitial());

  Future<void> getComments({required String postId}) async {
    emit(CommentsLoading());

    try {
      final comments = await getCommentsUseCase(postId: postId);

      emit(CommentsLoaded(comments));
    } catch (e) {
      emit(const CommentsError('Failed to load comments.'));
    }
  }

  Future<bool> addComment({
    required String postId,
    required String content,
  }) async {
    final currentState = state;

    if (currentState is! CommentsLoaded) {
      return false;
    }

    final currentComments = List<CommentEntity>.from(currentState.comments);

    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return false;
    }

    final trimmedContent = content.trim();

    if (trimmedContent.isEmpty) {
      return false;
    }

    final temporaryComment = CommentEntity(
      id: 'local_${DateTime.now().microsecondsSinceEpoch}',
      postId: postId,
      userId: currentUser.uid,
      userName: currentUser.displayName ?? 'User',
      userImage: currentUser.photoURL,
      content: trimmedContent,
      createdAt: DateTime.now(),
    );

    final optimisticComments = [...currentComments, temporaryComment];

    emit(CommentAdding(optimisticComments));

    try {
      final createdComment = await addCommentUseCase(
        postId: postId,
        content: trimmedContent,
      );

      final updatedComments = List<CommentEntity>.from(optimisticComments);

      final temporaryIndex = updatedComments.indexWhere(
        (comment) => comment.id == temporaryComment.id,
      );

      if (temporaryIndex != -1) {
        updatedComments[temporaryIndex] = createdComment;
      } else {
        updatedComments.add(createdComment);
      }

      emit(CommentsLoaded(updatedComments));

      return true;
    } catch (e) {
      // Rollback.
      emit(CommentsLoaded(currentComments));

      return false;
    }
  }

  Future<bool> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    final currentState = state;

    if (currentState is! CommentsLoaded) {
      return false;
    }

    final currentComments = List<CommentEntity>.from(currentState.comments);

    final commentIndex = currentComments.indexWhere(
      (comment) => comment.id == commentId,
    );

    if (commentIndex == -1) {
      return false;
    }

    final deletedComment = currentComments[commentIndex];

    final optimisticComments = List<CommentEntity>.from(currentComments)
      ..removeAt(commentIndex);

    emit(CommentDeleting(optimisticComments));

    try {
      await deleteCommentUseCase(postId: postId, commentId: commentId);

      emit(CommentsLoaded(optimisticComments));

      return true;
    } catch (e) {
      final rollbackComments = List<CommentEntity>.from(optimisticComments)
        ..insert(commentIndex, deletedComment);

      emit(CommentsLoaded(rollbackComments));

      return false;
    }
  }
}
