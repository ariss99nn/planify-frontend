// lib/features/ficha/presentation/widgets/views/ficha_estudiante_add_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/theme.dart';
import '../../providers/ficha_provider.dart';
import '../../../data/models/ficha_request_model.dart';

class FichaEstudianteAddView extends StatefulWidget {
  final int fichaId;
  const FichaEstudianteAddView({super.key, required this.fichaId});

  @override
  State<FichaEstudianteAddView> createState() => _FichaEstudianteAddViewState();
}

class _FichaEstudianteAddViewState extends State<FichaEstudianteAddView> {
  final _formKey         = GlobalKey<FormState>();
  final _estudianteIdCtrl = TextEditingController();
  bool _esCadena = false;

  @override
  void dispose() {
    _estudianteIdCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final estudianteId = int.tryParse(_estudianteIdCtrl.text.trim());
    if (estudianteId == null) return;

    final request = AddEstudianteRequest(
      estudianteId: estudianteId,
      esCadena:     _esCadena,
    );

    final provider = context.read<FichaProvider>();
    final rel = await provider.addEstudiante(widget.fichaId, request);

    if (!mounted) return;

    if (rel != null) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            provider.mutationError ?? 'No se pudo agregar al estudiante.'),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<FichaProvider>().loadingMutation;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        title: const Text('AGREGAR ESTUDIANTE',
            style: TextStyle(
                fontWeight: FontWeight.w700, fontSize: 15, letterSpacing: 2)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.border),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppTheme.primary.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: AppTheme.primary, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Ingresa el ID del estudiante.\n'
                        'El selector visual estará disponible próximamente.',
                        style: TextStyle(
                          color: AppTheme.textSecondary.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              TextFormField(
                controller: _estudianteIdCtrl,
                keyboardType: TextInputType.number,
                autofocus: true,
                style: const TextStyle(
                    color: AppTheme.textPrimary, fontSize: 18),
                decoration: InputDecoration(
                  labelText: 'ID del estudiante',
                  prefixIcon: const Icon(Icons.person_search_outlined,
                      color: AppTheme.primary),
                  labelStyle: TextStyle(
                      color: AppTheme.textSecondary.withOpacity(0.8)),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Campo requerido';
                  if (int.tryParse(v.trim()) == null) return 'Debe ser numérico';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: AppTheme.border.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppTheme.accent,
                  title: const Text('Cadena de formación',
                      style: TextStyle(
                          color: AppTheme.textPrimary, fontSize: 14)),
                  subtitle: Text(
                    'El estudiante proviene de cadena.',
                    style: TextStyle(
                        color: AppTheme.textSecondary.withOpacity(0.6),
                        fontSize: 11),
                  ),
                  value:     _esCadena,
                  onChanged: (v) => setState(() => _esCadena = v),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: AppTheme.background,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: loading
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Agregar estudiante',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
