import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/theme.dart';

class CyberAvatarPicker extends StatelessWidget {
  final Uint8List? imageBytes;
  final VoidCallback onTap;

  const CyberAvatarPicker({
    super.key,
    required this.imageBytes,
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
                  radius: 50,
                  backgroundColor: AppTheme.surfaceLight,
                  backgroundImage:
                      imageBytes != null ? MemoryImage(imageBytes!) : null,
                  child: imageBytes == null
                      ? const Icon(Icons.camera_alt,
                          size: 36, color: AppTheme.primary)
                      : null,
                ),
              ),
              CircleAvatar(
                radius: 14,
                backgroundColor: AppTheme.primary,
                child: const Icon(Icons.edit,
                    size: 14, color: Colors.black),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          imageBytes == null ? 'Toca para agregar foto' : 'Toca para cambiar foto',
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.primary,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}