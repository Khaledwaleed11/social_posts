import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CreatePostCard extends StatelessWidget {
  final VoidCallback onTap;

  const CreatePostCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser = FirebaseAuth.instance.currentUser;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.55,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  _ProfileAvatar(
                    imageUrl: currentUser?.photoURL,
                    name: currentUser?.displayName,
                    email: currentUser?.email,
                    radius: 21,
                    primaryColor: theme.colorScheme.primary,
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      "What's on your mind?",
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.50,
                        ),
                        fontSize: 14,
                      ),
                    ),
                  ),

                  Icon(
                    Icons.edit_rounded,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.image_outlined,
                  label: 'Photo',
                  color: Colors.green,
                  onTap: onTap,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionButton(
                  icon: Icons.text_fields_rounded,
                  label: 'Text',
                  color: theme.colorScheme.primary,
                  onTap: onTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ======================================================
// Profile Avatar
// ======================================================

class _ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final String? email;
  final double radius;
  final Color primaryColor;

  const _ProfileAvatar({
    required this.imageUrl,
    required this.name,
    required this.email,
    required this.radius,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    final initial = name != null && name!.trim().isNotEmpty
        ? name!.trim()[0].toUpperCase()
        : email != null && email!.isNotEmpty
        ? email![0].toUpperCase()
        : 'U';

    final size = radius * 2;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: primaryColor.withValues(alpha: 0.10),
      ),
      child: ClipOval(
        child: hasImage
            ? Image.network(
                imageUrl!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildInitial(initial);
                },
              )
            : _buildInitial(initial),
      ),
    );
  }

  Widget _buildInitial(String initial) {
    return Center(
      child: Text(
        initial,
        style: TextStyle(
          color: primaryColor,
          fontSize: radius * 0.75,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

// ======================================================
// Action Button
// ======================================================

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 19, color: color),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(fontWeight: FontWeight.w600, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
