import 'package:flutter/material.dart';
import '../theme/theme.dart';

class CyberEmailChip extends StatelessWidget {
  final String email;

  const CyberEmailChip({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryDark),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.email_outlined, size: 16, color: AppTheme.primary),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              email,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}