import 'package:flutter/material.dart';

import '../../data/models/competencia_model.dart';
import '../../competencia_theme.dart';

class CompetenciaCard extends StatelessWidget {
  final CompetenciaItem item;
  final VoidCallback?   onTap;

  const CompetenciaCard({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: CT.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: CT.border.withOpacity(0.6)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: item.isPrincipal
              ? CT.principal.withOpacity(0.15)
              : CT.transversal.withOpacity(0.15),
          child: Icon(
            item.isPrincipal ? Icons.star_outline : Icons.public_outlined,
            color: item.isPrincipal ? CT.principal : CT.transversal,
            size: 20,
          ),
        ),
        title: Text(item.nombre,
            style: const TextStyle(
                color: CT.textPrimary, fontWeight: FontWeight.w600)),
        subtitle: Text(item.codigo,
            style: const TextStyle(color: CT.textSec, fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, color: CT.textSec),
      ),
    );
  }
}
