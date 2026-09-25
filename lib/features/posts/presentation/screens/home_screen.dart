import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/animations/animated_feed_item.dart';
import '../../../../core/dependency_injection/injection_container.dart';
import '../../../comments/presentation/cubit/comments_cubit.dart';
import '../../../comments/presentation/screens/comments_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../cubit/posts_cubit.dart';
import '../cubit/posts_state.dart';
import '../widgets/create_post_card.dart';
import '../widgets/post_card.dart';
import '../widgets/post_skeleton.dart';
import 'create_post_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final PostsCubit _postsCubit;

  @override
  void initState() {
    super.initState();

    _postsCubit = sl<PostsCubit>();
    _postsCubit.getPosts();
  }

  @override
  void dispose() {
    _postsCubit.close();
    super.dispose();
  }

  Future<void> _openCreatePost() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: _postsCubit,
          child: const CreatePostScreen(),
        ),
      ),
    );
  }

  Future<void> _openComments(String postId) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) {
        return BlocProvider(
          create: (_) => sl<CommentsCubit>(),
          child: FractionallySizedBox(
            heightFactor: 0.82,
            child: CommentsScreen(
              postId: postId,
              onCommentsCountChanged: (delta) {
                _postsCubit.updateCommentsCount(postId: postId, delta: delta);
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _deletePost(String postId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete post?'),
          content: const Text('This post will be permanently deleted.'),
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

    if (confirmed != true) {
      return;
    }

    await _postsCubit.deletePost(postId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser = FirebaseAuth.instance.currentUser;

    return BlocProvider.value(
      value: _postsCubit,
      child: Scaffold(
        backgroundColor: theme.colorScheme.surfaceContainerLowest,
        body: SafeArea(
          child: RefreshIndicator(
            color: theme.colorScheme.primary,
            backgroundColor: theme.colorScheme.surface,
            onRefresh: _postsCubit.getPosts,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                // ==================================================
                // HEADER
                // ==================================================
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Social Posts',
                                style: TextStyle(
                                  fontSize: 28,
                                  height: 1.1,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.7,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Share moments. Stay connected.',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.50,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 14),

                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ProfileScreen(),
                              ),
                            );
                          },
                          child: _ProfileAvatar(
                            imageUrl: currentUser?.photoURL,
                            name: currentUser?.displayName,
                            email: currentUser?.email,
                            size: 50,
                            primaryColor: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ==================================================
                // CREATE POST
                // ==================================================
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
                    child: CreatePostCard(onTap: _openCreatePost),
                  ),
                ),

                // ==================================================
                // SECTION HEADER
                // ==================================================
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Recent Posts',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),

                        const SizedBox(width: 8),

                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),

                        const Spacer(),

                        BlocBuilder<PostsCubit, PostsState>(
                          builder: (context, state) {
                            if (state is PostsLoaded) {
                              return AnimatedSwitcher(
                                duration: const Duration(milliseconds: 220),
                                child: Text(
                                  '${state.posts.length} '
                                  '${state.posts.length == 1 ? 'post' : 'posts'}',
                                  key: ValueKey(state.posts.length),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.42),
                                  ),
                                ),
                              );
                            }

                            return const SizedBox.shrink();
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // ==================================================
                // FEED
                // ==================================================
                BlocBuilder<PostsCubit, PostsState>(
                  builder: (context, state) {
                    // ----------------------------------------------
                    // SKELETON
                    // ----------------------------------------------
                    if (state is PostsLoading) {
                      return SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            return const PostSkeleton();
                          }, childCount: 3),
                        ),
                      );
                    }

                    // ----------------------------------------------
                    // ERROR
                    // ----------------------------------------------
                    if (state is PostsError) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: _ErrorView(
                          message: state.message,
                          onRetry: _postsCubit.getPosts,
                        ),
                      );
                    }

                    // ----------------------------------------------
                    // LOADED
                    // ----------------------------------------------
                    if (state is PostsLoaded) {
                      if (state.posts.isEmpty) {
                        return SliverFillRemaining(
                          hasScrollBody: false,
                          child: _EmptyPostsView(onCreatePost: _openCreatePost),
                        );
                      }

                      return SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final post = state.posts[index];

                            return AnimatedFeedItem(
                              index: index,
                              child: PostCard(
                                post: post,
                                currentUserId: currentUser?.uid ?? '',
                                onLike: () {
                                  if (currentUser == null) {
                                    return;
                                  }

                                  _postsCubit.toggleLike(
                                    postId: post.id,
                                    userId: currentUser.uid,
                                  );
                                },
                                onDelete: post.userId == currentUser?.uid
                                    ? () => _deletePost(post.id)
                                    : null,
                                onComment: () {
                                  _openComments(post.id);
                                },
                              ),
                            );
                          }, childCount: state.posts.length),
                        ),
                      );
                    }

                    return const SliverFillRemaining(
                      hasScrollBody: false,
                      child: SizedBox.shrink(),
                    );
                  },
                ),

                // ==================================================
                // BOTTOM SPACE
                // ==================================================
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ================================================================
// PROFILE AVATAR
// ================================================================

class _ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final String? email;
  final double size;
  final Color primaryColor;

  const _ProfileAvatar({
    required this.imageUrl,
    required this.name,
    required this.email,
    required this.size,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = name?.trim().isNotEmpty == true
        ? name!.trim()
        : email?.trim().isNotEmpty == true
        ? email!.trim()
        : 'User';

    final firstLetter = displayName[0].toUpperCase();

    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: primaryColor.withValues(alpha: 0.15),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.14),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _fallback(firstLetter);
                },
              )
            : _fallback(firstLetter),
      ),
    );
  }

  Widget _fallback(String letter) {
    return Container(
      color: primaryColor,
      alignment: Alignment.center,
      child: Text(
        letter,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.38,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

// ================================================================
// EMPTY POSTS
// ================================================================

class _EmptyPostsView extends StatelessWidget {
  final VoidCallback onCreatePost;

  const _EmptyPostsView({required this.onCreatePost});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.forum_outlined,
                size: 38,
                color: theme.colorScheme.primary,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'No posts yet',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Be the first to share something\n'
              'with the community.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.50),
              ),
            ),

            const SizedBox(height: 20),

            FilledButton.icon(
              onPressed: onCreatePost,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create your first post'),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// ERROR
// ================================================================

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                size: 34,
                color: theme.colorScheme.error,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: 7),

            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.50),
              ),
            ),

            const SizedBox(height: 20),

            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
