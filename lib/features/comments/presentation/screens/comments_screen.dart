import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/comment_entity.dart';
import '../cubit/comments_cubit.dart';
import '../cubit/comments_state.dart';
import '../widgets/comment_card.dart';
import '../widgets/comment_input.dart';

class CommentsScreen extends StatefulWidget {
  final String postId;
  final ValueChanged<int>? onCommentsCountChanged;

  const CommentsScreen({
    super.key,
    required this.postId,
    this.onCommentsCountChanged,
  });

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<CommentsCubit>().getComments(postId: widget.postId);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _hideKeyboard() {
    FocusScope.of(context).unfocus();
  }

  Future<void> _scrollToBottom() async {
    if (!_scrollController.hasClients) return;

    await Future.delayed(const Duration(milliseconds: 80));

    if (!_scrollController.hasClients) return;

    await _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _hideKeyboard,
        child: Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Comments',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Join the conversation',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.50,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _hideKeyboard();
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),

              Divider(
                height: 1,
                color: theme.colorScheme.outline.withValues(alpha: 0.08),
              ),

              // Comments
              Expanded(
                child: BlocBuilder<CommentsCubit, CommentsState>(
                  builder: (context, state) {
                    if (state is CommentsLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is CommentsError) {
                      return _ErrorView(
                        message: state.message,
                        onRetry: () {
                          context.read<CommentsCubit>().getComments(
                            postId: widget.postId,
                          );
                        },
                      );
                    }

                    List<CommentEntity> comments = [];

                    if (state is CommentsLoaded) {
                      comments = state.comments;
                    } else if (state is CommentAdding) {
                      comments = state.comments;
                    } else if (state is CommentDeleting) {
                      comments = state.comments;
                    }

                    if (comments.isEmpty) {
                      return const _EmptyCommentsView();
                    }

                    return GestureDetector(
                      onTap: _hideKeyboard,
                      child: ListView.builder(
                        controller: _scrollController,
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index];

                          return CommentCard(
                            comment: comment,
                            currentUserId: currentUserId,
                            onDelete: comment.userId == currentUserId
                                ? () {
                                    _showDeleteConfirmation(context, comment);
                                  }
                                : null,
                          );
                        },
                      ),
                    );
                  },
                ),
              ),

              BlocBuilder<CommentsCubit, CommentsState>(
                builder: (context, state) {
                  final isLoading = state is CommentAdding;

                  return CommentInput(
                    isLoading: isLoading,
                    onSend: (content) async {
                      final success = await context
                          .read<CommentsCubit>()
                          .addComment(postId: widget.postId, content: content);

                      if (!mounted) return;

                      if (success) {
                        widget.onCommentsCountChanged?.call(1);

                        await _scrollToBottom();
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    CommentEntity comment,
  ) async {
    _hideKeyboard();

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete comment?'),
          content: const Text('This comment will be permanently deleted.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    if (!mounted) return;

    final success = await context.read<CommentsCubit>().deleteComment(
      postId: widget.postId,
      commentId: comment.id,
    );

    if (!mounted) return;

    if (success) {
      widget.onCommentsCountChanged?.call(-1);
    }
  }
}

class _EmptyCommentsView extends StatelessWidget {
  const _EmptyCommentsView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.forum_outlined,
                size: 30,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No comments yet',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'Be the first to start the conversation.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 42,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}
