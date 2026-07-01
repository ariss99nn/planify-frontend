import 'package:flutter/material.dart';
import '../theme/theme.dart';

class CyberProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;

  const CyberProfileAvatar({
    super.key,
    this.imageUrl,
    this.radius = 50,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.primary, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.2),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: AppTheme.surfaceLight,
        backgroundImage:
            imageUrl != null ? NetworkImage(imageUrl!) : null,
        onBackgroundImageError:
            imageUrl != null ? (_, __) {} : null,
        child: imageUrl == null
            ? Icon(Icons.person, size: radius * 1.1, color: AppTheme.primary)
            : null,
      ),
    );
  }
}