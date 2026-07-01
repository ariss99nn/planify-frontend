import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../theme/theme.dart';

class CyberEditAvatar extends StatelessWidget {
  final ImageProvider? image;
  final VoidCallback onTap;

  const CyberEditAvatar({
    super.key,
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.primary, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 56,
                  backgroundColor: AppTheme.primary.withOpacity(0.1),
                  backgroundImage: image,
                  onBackgroundImageError:
                      image != null ? (_, __) {} : null,
                  child: image == null
                      ? const Icon(Icons.person,
                          size: 56, color: AppTheme.primary)
                      : null,
                ),
              ),
              CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.primary,
                child: const Icon(Icons.camera_alt,
                    size: 15, color: Colors.black),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          image == null ? 'Agregar foto (opcional)' : 'Toca para cambiar',
          style: const TextStyle(
              fontSize: 12, color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}