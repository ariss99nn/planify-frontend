import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../domain/entities/novedad_entity.dart';
import '../providers/novedad_provider.dart';

class AtenderNovedadDialog extends StatefulWidget {
  const AtenderNovedadDialog({
    super.key,
    required this.novedad,
    required this.provider,
  });

  final NovedadEntity novedad;
  final NovedadProvider provider;

  static Future<bool?> mostrar(
    BuildContext context, {
    required NovedadEntity novedad,
    required NovedadProvider provider,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) =>
          AtenderNovedadDialog(novedad: novedad, provider: provider),
    );
  }

  @override
  State<AtenderNovedadDialog> createState() => _AtenderNovedadDialogState();
}

class _AtenderNovedadDialogState extends State<AtenderNovedadDialog> {
  final _formKey = GlobalKey<FormState>();
  final _notaController = TextEditingController();

  @override
  void dispose() {
    _notaController.dispose();
    super.dispose();
  }

  Future<void> _confirmar() async {
    if (!_formKey.currentState!.validate()) return;

    final ok = await widget.provider.atender(
      id: widget.novedad.id,
      notaAtencion: _notaController.text.trim(),
    );

    if (!mounted) return;

    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(widget.provider.error ?? 'No se pudo atender la novedad.'),
          backgroundColor: Colors.redAccent.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.provider,
      builder: (context, _) {
        final enviando = widget.provider.enviando;
        return AlertDialog(
          backgroundColor: AppTheme.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Atender novedad'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.novedad.titulo,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notaController,
                  maxLines: 4,
                  autofocus: true,
                  enabled: !enviando,
                  decoration: const InputDecoration(
                    labelText: 'Qué se hizo para resolverla',
                    hintText: 'Ej: se reasignó al docente X al bloque Y',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Describe brevemente la acción tomada.';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed:
                  enviando ? null : () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: enviando ? null : _confirmar,
              child: enviando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : const Text('Marcar como atendida'),
            ),
          ],
        );
      },
    );
  }
}
