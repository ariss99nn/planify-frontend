import 'package:flutter/material.dart';
import '../theme/theme.dart';

class CyberFieldLabel extends StatelessWidget {
  final String text;
  final bool required;

  const CyberFieldLabel(this.text, {super.key, this.required = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: AppTheme.textSecondary,
              letterSpacing: 0.2,
            ),
          ),
          if (required) ...[
            const SizedBox(width: 4),
            const Text(
              '*',
              style: TextStyle(color: Colors.redAccent, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}