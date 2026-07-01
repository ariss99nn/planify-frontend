// lib/features/ficha/presentation/widgets/ficha_form_fields.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class FichaSeccionLabel extends StatelessWidget {
  final String titulo;
  const FichaSeccionLabel(this.titulo, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Text(
        titulo,
        style: const TextStyle(
          color: AppTheme.primary,
          fontWeight: FontWeight.w700,
          fontSize: 12,
          letterSpacing: 2,
        ),
      ),
    );
  }
}

class FichaDropdownField extends StatelessWidget {
  final String label;
  final String value;
  final Map<String, String> opciones;
  final ValueChanged<String?> onChanged;

  const FichaDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.opciones,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: AppTheme.surface,
      style: const TextStyle(color: AppTheme.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppTheme.textSecondary.withOpacity(0.8)),
      ),
      items: opciones.entries
          .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
          .toList(),
      onChanged: onChanged,
    );
  }
}

class FichaFechaTile extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const FichaFechaTile({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppTheme.textSecondary.withOpacity(0.8)),
          prefixIcon: const Icon(Icons.calendar_today, color: AppTheme.primary),
        ),
        child: Text(value, style: const TextStyle(color: AppTheme.textPrimary)),
      ),
    );
  }
}
