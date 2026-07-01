import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../theme/theme.dart';

class CyberImagePickerField extends StatelessWidget {
  final Uint8List? localBytes;
  final String? networkUrl;
  final VoidCallback onTap;
  final double height;

  const CyberImagePickerField({
    super.key,
    required this.onTap,
    this.localBytes,
    this.networkUrl,
    this.height = 120,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (localBytes != null) {
      return Image.memory(localBytes!, fit: BoxFit.cover, width: double.infinity);
    }
    if (networkUrl != null && networkUrl!.isNotEmpty) {
      return Image.network(
        networkUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add_photo_alternate_outlined,
              color: AppTheme.primary, size: 32),
          SizedBox(height: 6),
          Text(
            'Seleccionar imagen',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}