import 'package:flutter/material.dart';
import '../theme/theme.dart';

class CyberInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final double iconSize;
  final double fontSize;

  const CyberInfoRow({
    super.key,
    required this.icon,
    required this.text,
    this.iconSize = 18,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: iconSize, color: AppTheme.primary),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              color: AppTheme.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}