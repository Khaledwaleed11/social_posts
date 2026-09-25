import 'package:flutter/material.dart';

import '../../../../core/animations/app_animations.dart';
import '../../domain/entities/post_entity.dart';
import 'animated_like_button.dart';

class PostCard extends StatefulWidget {
  final PostEntity post;
  final String currentUserId;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback? onDelete;

  const PostCard({
    super.key,
    required this.post,
    required this.currentUserId,
    required this.onLike,
    required this.onComment,
    this.onDelete,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<Offset> _slideAnimation;

  bool get isLiked => widget.post.likedBy.contains(widget.currentUserId);

  bool get isOwner => widget.post.userId == widget.currentUserId;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: AppAnimations.medium,
    );

    final curvedAnimation = CurvedAnimation(
      parent: _animationController,
      curve: AppAnimations.standard,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);

    _scaleAnimation = Tween<double>(
      begin: 0.98,
      end: 1,
    ).animate(curvedAnimation);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.025),
      end: Offset.zero,
    ).animate(curvedAnimation);

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    }

    if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;

      return '$minutes ${minutes == 1 ? 'min' : 'mins'} ago';
    }

    if (difference.inHours < 24) {
      final hours = difference.inHours;

      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    }

    if (difference.inDays < 7) {
      final days = difference.inDays;

      return '$days ${days == 1 ? 'day' : 'days'} ago';
    }

    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  void _openImageViewer() {
    if (widget.post.imageUrl == null || widget.post.imageUrl!.isEmpty) {
      return;
    }

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black.withValues(alpha: 0.92),
        transitionDuration: AppAnimations.normal,
        reverseTransitionDuration: AppAnimations.fast,
        pageBuilder: (context, animation, secondaryAnimation) {
          return _PostImageViewer(imageUrl: widget.post.imageUrl!);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: AppAnimations.standard,
          );

          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.94, end: 1).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  void _showPostMenu() {
    if (!isOwner || widget.onDelete == null) {
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);

        return Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 18),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  leading: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.delete_outline_rounded,
                      color: theme.colorScheme.error,
                    ),
                  ),
                  title: const Text(
                    'Delete post',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    'Remove this post permanently',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.50,
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    widget.onDelete?.call();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final imageUrl = widget.post.userImage;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.06),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.035),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --------------------------------------------------
                // Header
                // --------------------------------------------------
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 12, 12),
                  child: Row(
                    children: [
                      _UserAvatar(
                        imageUrl: imageUrl,
                        name: widget.post.userName,
                        size: 46,
                        primaryColor: theme.colorScheme.primary,
                      ),

                      const SizedBox(width: 11),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.post.userName.isEmpty
                                  ? 'User'
                                  : widget.post.userName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Icon(
                                  Icons.public_rounded,
                                  size: 12,
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.40,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatTime(widget.post.createdAt),
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.45),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      if (isOwner)
                        IconButton(
                          onPressed: _showPostMenu,
                          splashRadius: 22,
                          tooltip: 'More',
                          icon: Icon(
                            Icons.more_horiz_rounded,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.55,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // --------------------------------------------------
                // Content
                // --------------------------------------------------
                if (widget.post.content.trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                    child: Text(
                      widget.post.content,
                      style: TextStyle(
                        fontSize: 14.5,
                        height: 1.55,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),

                // --------------------------------------------------
                // Post Image
                // --------------------------------------------------
                if (widget.post.imageUrl != null &&
                    widget.post.imageUrl!.isNotEmpty)
                  GestureDetector(
                    onTap: _openImageViewer,
                    child: Hero(
                      tag: 'post_image_${widget.post.id}',
                      child: AspectRatio(
                        aspectRatio: 1.15,
                        child: Image.network(
                          widget.post.imageUrl!,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            }

                            return Container(
                              color: theme.colorScheme.surfaceContainerHighest,
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: theme.colorScheme.surfaceContainerHighest,
                              child: const Center(
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  size: 36,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                // --------------------------------------------------
                // Stats
                // --------------------------------------------------
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 13, 16, 8),
                  child: Row(
                    children: [
                      if (widget.post.likesCount > 0)
                        _LikeCount(
                          count: widget.post.likesCount,
                          primaryColor: theme.colorScheme.primary,
                        ),

                      const Spacer(),

                      if (widget.post.commentsCount > 0)
                        Text(
                          '${widget.post.commentsCount} '
                          '${widget.post.commentsCount == 1 ? 'comment' : 'comments'}',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.45,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: theme.colorScheme.outline.withValues(alpha: 0.07),
                ),

                // --------------------------------------------------
                // Actions
                // --------------------------------------------------
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: AnimatedLikeButton(
                          isLiked: isLiked,
                          likesCount: widget.post.likesCount,
                          onTap: widget.onLike,
                        ),
                      ),
                      Expanded(
                        child: _PostActionButton(
                          icon: Icons.chat_bubble_outline_rounded,
                          label: 'Comment',
                          onTap: widget.onComment,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double size;
  final Color primaryColor;

  const _UserAvatar({
    required this.imageUrl,
    required this.name,
    required this.size,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final firstLetter = name.trim().isNotEmpty
        ? name.trim()[0].toUpperCase()
        : 'U';

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          imageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _fallbackAvatar(firstLetter);
          },
        ),
      );
    }

    return _fallbackAvatar(firstLetter);
  }

  Widget _fallbackAvatar(String letter) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            primaryColor,
            Color.lerp(primaryColor, Colors.white, 0.35) ?? primaryColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.38,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _LikeCount extends StatelessWidget {
  final int count;
  final Color primaryColor;

  const _LikeCount({required this.count, required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.redAccent.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.favorite_rounded,
            size: 11,
            color: Colors.redAccent,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface
                .withValues(alpha: 0.50),
          ),
        ),
      ],
    );
  }
}

class _PostActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PostActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.58),
              ),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.58),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PostImageViewer extends StatelessWidget {
  final String imageUrl;

  const _PostImageViewer({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Center(
            child: Hero(
              tag: 'post_image_viewer_$imageUrl',
              child: InteractiveViewer(
                minScale: 0.8,
                maxScale: 4,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.broken_image_outlined,
                      color: Colors.white,
                      size: 50,
                    );
                  },
                ),
              ),
            ),
          ),

          Positioned(
            top: MediaQuery.paddingOf(context).top + 12,
            right: 16,
            child: Material(
              color: Colors.black.withValues(alpha: 0.45),
              shape: const CircleBorder(),
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                customBorder: const CircleBorder(),
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(Icons.close_rounded, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
