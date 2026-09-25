import 'package:flutter/material.dart';

class PostSkeleton extends StatefulWidget {
  const PostSkeleton({super.key});

  @override
  State<PostSkeleton> createState() => _PostSkeletonState();
}

class _PostSkeletonState extends State<PostSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.35,
      end: 0.75,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _skeletonBox({
    required double width,
    required double height,
    double radius = 10,
  }) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: _animation.value),
            borderRadius: BorderRadius.circular(radius),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.06),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User header
            Row(
              children: [
                _skeletonBox(width: 46, height: 46, radius: 23),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _skeletonBox(width: 110, height: 13, radius: 6),
                      const SizedBox(height: 8),
                      _skeletonBox(width: 75, height: 9, radius: 5),
                    ],
                  ),
                ),
                _skeletonBox(width: 28, height: 28, radius: 14),
              ],
            ),

            const SizedBox(height: 18),

            // Content
            _skeletonBox(width: double.infinity, height: 13, radius: 6),
            const SizedBox(height: 9),
            _skeletonBox(width: double.infinity, height: 13, radius: 6),
            const SizedBox(height: 9),
            _skeletonBox(width: 190, height: 13, radius: 6),

            const SizedBox(height: 16),

            // Image placeholder
            _skeletonBox(width: double.infinity, height: 210, radius: 16),

            const SizedBox(height: 16),

            // Stats
            Row(
              children: [
                _skeletonBox(width: 55, height: 10, radius: 5),
                const Spacer(),
                _skeletonBox(width: 75, height: 10, radius: 5),
              ],
            ),

            const SizedBox(height: 14),

            Divider(
              height: 1,
              color: theme.colorScheme.outline.withValues(alpha: 0.06),
            ),

            const SizedBox(height: 8),

            // Actions
            Row(
              children: [
                Expanded(
                  child: Center(
                    child: _skeletonBox(width: 80, height: 30, radius: 10),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: _skeletonBox(width: 90, height: 30, radius: 10),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
