// lib/core/widgets/cyber_status_badge.dart

import 'package:flutter/material.dart';
import '../theme/theme.dart';

class CyberStatusBadge extends StatelessWidget {
  final String label;
  final Color? color;

  const CyberStatusBadge({super.key, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: (color ?? AppTheme.primary).withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color ?? AppTheme.primary,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}