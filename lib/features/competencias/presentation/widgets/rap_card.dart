import 'package:flutter/material.dart';

import '../../competencia_theme.dart';
import '../../data/models/rap_model.dart';

class RapCard extends StatelessWidget {
  final RapItem   item;
  final VoidCallback? onTap;

  const RapCard({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: CT.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: CT.border.withOpacity(0.6)),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: const Icon(Icons.task_alt_outlined, color: CT.accent),
        title: Text(
          item.codigo,
          style: const TextStyle(
              color: CT.textPrimary, fontWeight: FontWeight.w600, fontSize: 13),
        ),
        subtitle: Text(
          item.descripcion,
          style: const TextStyle(color: CT.textSec, fontSize: 12),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right, color: CT.textSec),
        onTap: onTap,
      ),
    );
  }
}
