import 'package:flutter/material.dart';

import '../../competencia_theme.dart';
import '../../data/models/asignatura_model.dart';

class AsignaturaCard extends StatelessWidget {
  final AsignaturaItem item;
  final VoidCallback?  onTap;

  const AsignaturaCard({super.key, required this.item, this.onTap});

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
        leading: const Icon(Icons.book_outlined, color: CT.primary),
        title: Text(
          item.nombre,
          style: const TextStyle(
              color: CT.textPrimary, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          item.tipoDisplay,
          style: const TextStyle(color: CT.textSec, fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right, color: CT.textSec),
        onTap: onTap,
      ),
    );
  }
}
