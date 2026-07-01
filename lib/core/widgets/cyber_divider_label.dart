import 'package:flutter/material.dart';
import '../theme/theme.dart';

class CyberDividerLabel extends StatelessWidget {
  final String label;

  const CyberDividerLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: AppTheme.border, thickness: 0.5)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(label, style: Theme.of(context).textTheme.bodySmall),
        ),
        Expanded(child: Divider(color: AppTheme.border, thickness: 0.5)),
      ],
    );
  }
}