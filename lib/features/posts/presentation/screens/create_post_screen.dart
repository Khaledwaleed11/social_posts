import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../cubit/posts_cubit.dart';
import '../cubit/posts_state.dart';

class CreatePostScreen extends StatefulWidget {
  final bool autoOpenGallery;

  const CreatePostScreen({super.key, this.autoOpenGallery = false});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen>
    with SingleTickerProviderStateMixin {
  static const int _maxCharacters = 500;

  final TextEditingController _controller = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  File? _selectedImage;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    final curvedAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(curvedAnimation);

    _controller.addListener(_onTextChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _animationController.forward();

      if (widget.autoOpenGallery) {
        Future.delayed(const Duration(milliseconds: 250), () {
          if (mounted) {
            _pickImage();
          }
        });
      }
    });
  }

  void _onTextChanged() {
    if (_controller.text.length > _maxCharacters) {
      _controller.text = _controller.text.substring(0, _maxCharacters);

      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _hideKeyboard() {
    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // ============================================================
  // Pick Image
  // ============================================================

  Future<void> _pickImage() async {
    if (_isCreating) return;

    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        return;
      }

      if (!mounted) return;

      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to select image.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    }
  }

  // ============================================================
  // Remove Image
  // ============================================================

  void _removeImage() {
    if (_isCreating) return;

    setState(() {
      _selectedImage = null;
    });
  }

  // ============================================================
  // Create Post
  // ============================================================

  Future<void> _createPost(BuildContext context) async {
    final content = _controller.text.trim();

    if (content.isEmpty && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Write something or add a photo first.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
      return;
    }

    _hideKeyboard();

    setState(() {
      _isCreating = true;
    });

    await context.read<PostsCubit>().createPost(content, image: _selectedImage);

    if (!mounted) return;

    final state = context.read<PostsCubit>().state;

    if (state is PostsLoaded) {
      Navigator.pop(context, true);
      return;
    }

    setState(() {
      _isCreating = false;
    });

    if (state is PostsError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    }
  }

  // ============================================================
  // Build
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final currentUser = FirebaseAuth.instance.currentUser;

    final userName = currentUser?.displayName?.trim().isNotEmpty == true
        ? currentUser!.displayName!.trim()
        : 'You';

    final userImage = currentUser?.photoURL;

    final characterCount = _controller.text.length;

    // Same keyboard handling approach used in CommentsScreen.
    final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;

    return PopScope(
      canPop: !_isCreating,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        _hideKeyboard();
      },
      child: Scaffold(
        // Important:
        // AnimatedPadding handles the keyboard inset manually.
        resizeToAvoidBottomInset: false,

        appBar: AppBar(
          automaticallyImplyLeading: false,
          titleSpacing: 20,
          title: const Text(
            'Create Post',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: TextButton(
                onPressed: _isCreating
                    ? null
                    : () {
                        _hideKeyboard();
                        Navigator.pop(context);
                      },
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),

        body: AnimatedPadding(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.only(bottom: keyboardHeight),
          child: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: _hideKeyboard,
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ==================================================
                        // User Header
                        // ==================================================

                        Row(
                          children: [
                            _UserAvatar(
                              imageUrl: userImage,
                              name: userName,
                              size: 46,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Create a new post',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.50),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // ==================================================
                        // Composer
                        // ==================================================
                        Container(
                          padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: theme.colorScheme.outline.withValues(
                                alpha: 0.07,
                              ),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.025),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // ==========================================
                              // Text Field
                              // ==========================================

                              TextField(
                                controller: _controller,
                                minLines: 7,
                                maxLines: 12,
                                maxLength: _maxCharacters,
                                keyboardType: TextInputType.multiline,
                                textInputAction: TextInputAction.newline,
                                buildCounter:
                                    (
                                      context, {
                                      required currentLength,
                                      required isFocused,
                                      maxLength,
                                    }) {
                                      return const SizedBox.shrink();
                                    },
                                decoration: InputDecoration(
                                  hintText: "What's on your mind?",
                                  hintStyle: TextStyle(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.35),
                                    fontSize: 17,
                                    height: 1.5,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.6,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              const SizedBox(height: 6),

                              // ==========================================
                              // Character Counter
                              // ==========================================
                              Align(
                                alignment: Alignment.centerRight,
                                child: AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 180),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: characterCount >= _maxCharacters
                                        ? theme.colorScheme.error
                                        : theme.colorScheme.onSurface
                                              .withValues(alpha: 0.40),
                                  ),
                                  child: Text(
                                    '$characterCount/$_maxCharacters',
                                  ),
                                ),
                              ),

                              // ==========================================
                              // Image Preview
                              // ==========================================
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 280),
                                switchInCurve: Curves.easeOutCubic,
                                switchOutCurve: Curves.easeInCubic,
                                child: _selectedImage != null
                                    ? Padding(
                                        key: const ValueKey('image'),
                                        padding: const EdgeInsets.only(top: 14),
                                        child: _ImagePreview(
                                          image: _selectedImage!,
                                          onRemove: _removeImage,
                                        ),
                                      )
                                    : const SizedBox(key: ValueKey('no_image')),
                              ),

                              const SizedBox(height: 16),

                              // ==========================================
                              // Add Photo
                              // ==========================================
                              _AddPhotoButton(
                                hasImage: _selectedImage != null,
                                isLoading: _isCreating,
                                onTap: _pickImage,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        // ==================================================
                        // Publish Button
                        // ==================================================
                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isCreating
                                ? null
                                : () => _createPost(context),
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              disabledBackgroundColor: theme.colorScheme.primary
                                  .withValues(alpha: 0.55),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(17),
                              ),
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 180),
                              child: _isCreating
                                  ? const Row(
                                      key: ValueKey('loading'),
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 21,
                                          height: 21,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.3,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          'Publishing...',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    )
                                  : const Row(
                                      key: ValueKey('publish'),
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.send_rounded, size: 20),
                                        SizedBox(width: 9),
                                        Text(
                                          'Publish Post',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ==================================================
                        // Helper Text
                        // ==================================================
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              size: 14,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.38,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Share something with the community',
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.38,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// User Avatar
// ============================================================

class _UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double size;

  const _UserAvatar({
    required this.imageUrl,
    required this.name,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final firstLetter = name.trim().isNotEmpty
        ? name.trim()[0].toUpperCase()
        : 'U';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.18),
          width: 2,
        ),
      ),
      child: ClipOval(
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _fallbackAvatar(context, firstLetter);
                },
              )
            : _fallbackAvatar(context, firstLetter),
      ),
    );
  }

  Widget _fallbackAvatar(BuildContext context, String letter) {
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.primary.withValues(alpha: 0.10),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: TextStyle(
          fontSize: size * 0.38,
          fontWeight: FontWeight.w800,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

// ============================================================
// Add Photo Button
// ============================================================

class _AddPhotoButton extends StatelessWidget {
  final bool hasImage;
  final bool isLoading;
  final VoidCallback onTap;

  const _AddPhotoButton({
    required this.hasImage,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.primary.withValues(alpha: 0.055),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  hasImage ? Icons.edit_rounded : Icons.image_outlined,
                  color: theme.colorScheme.primary,
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasImage ? 'Change photo' : 'Add a photo',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      hasImage
                          ? 'Choose another image'
                          : 'Choose an image from your gallery',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.48,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Image Preview
// ============================================================

class _ImagePreview extends StatelessWidget {
  final File image;
  final VoidCallback onRemove;

  const _ImagePreview({required this.image, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(19),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 16 / 10,
            child: Image.file(image, width: double.infinity, fit: BoxFit.cover),
          ),

          // Dark gradient overlay
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.18),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.08),
                  ],
                ),
              ),
            ),
          ),

          // Remove button
          Positioned(
            top: 10,
            right: 10,
            child: Material(
              color: Colors.black.withValues(alpha: 0.62),
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onRemove,
                customBorder: const CircleBorder(),
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 19,
                  ),
                ),
              ),
            ),
          ),

          // Photo label
          Positioned(
            left: 12,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.52),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.image_rounded, size: 14, color: Colors.white),
                  SizedBox(width: 5),
                  Text(
                    'Attached photo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
