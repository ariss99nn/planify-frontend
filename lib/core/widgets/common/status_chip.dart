// lib/widgets/common/status_chip.dart
import 'package:flutter/material.dart';
import '../../theme/theme.dart';

class StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const StatusChip({super.key, required this.label, required this.color});

  factory StatusChip.estado(String estadoValue, String display) {
    Color color;
    switch (estadoValue) {
      case 'ACTIVO':
        color = AppTheme.primary;
        break;
      case 'EN_REVISION':
        color = AppTheme.accent;
        break;
      default:
        color = AppTheme.textSecondary;
    }
    return StatusChip(label: display, color: color);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
