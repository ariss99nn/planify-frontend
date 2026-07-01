import 'package:flutter/material.dart';

class CyberWarningBadge extends StatelessWidget {
  final String label;
  final IconData icon;

  const CyberWarningBadge({
    super.key,
    required this.label,
    this.icon = Icons.warning_amber_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.shade900.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.shade700.withOpacity(0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.orange.shade400),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.orange.shade400),
          ),
        ],
      ),
    );
  }
}