import 'package:flutter/material.dart';

import 'app_animations.dart';

class AnimatedFeedItem extends StatefulWidget {
  final Widget child;
  final int index;

  const AnimatedFeedItem({super.key, required this.child, required this.index});

  @override
  State<AnimatedFeedItem> createState() => _AnimatedFeedItemState();
}

class _AnimatedFeedItemState extends State<AnimatedFeedItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: AppAnimations.medium,
    );

    final curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.standard,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);

    _scaleAnimation = Tween<double>(
      begin: 0.97,
      end: 1,
    ).animate(curvedAnimation);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(curvedAnimation);

    Future.delayed(AppAnimations.feedItemDelay(widget.index), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
      ),
    );
  }
}
