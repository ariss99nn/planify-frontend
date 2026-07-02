// lib/features/ficha/presentation/widgets/views/reasignacion_create_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/theme.dart';
import '../../../../../core/widgets/friendly_feedback.dart';
import '../../providers/ficha_provider.dart';
import '../../../data/models/ficha_request_model.dart';
import '../../../domain/entities/ficha_entity.dart';
import '../../../../auth/models/user_model.dart';
import '../ficha_pickers.dart';

class ReasignacionCreateView extends StatefulWidget {
  const ReasignacionCreateView({super.key});

  @override
  State<ReasignacionCreateView> createState() =>
      _ReasignacionCreateViewState();
}

class _ReasignacionCreateViewState extends State<ReasignacionCreateView> {
  final _formKey    = GlobalKey<FormState>();
  final _motivoCtrl = TextEditingController();

  UserModel? _estudiante;
  FichaListEntity? _fichaOrigen;
  FichaListEntity? _fichaDestino;

  @override
  void dispose() {
    _motivoCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickEstudiante() async {
    final picked = await pickEstudiante(context);
    if (picked == null) return;
    setState(() => _estudiante = picked);
  }

  // FIX: se reemplazó la hoja de búsqueda propia de esta pantalla (que
  // solo pedía la primera página de 15 fichas activas y por eso a veces
  // mostraba "Sin resultados" con catálogos más grandes) por el
  // selector compartido `pickFichaActiva`, que recorre automáticamente
  // todas las páginas de fichas activas al abrirse.
  Future<void> _pickFicha({required bool esOrigen}) async {
    final picked = await pickFichaActiva(
      context,
      excluirFichaId: esOrigen ? _fichaDestino?.id : _fichaOrigen?.id,
    );
    if (picked == null) return;
    setState(() {
      if (esOrigen) {
        _fichaOrigen = picked;
      } else {
        _fichaDestino = picked;
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_estudiante == null) {
      showFriendlySnack(context, 'Selecciona un estudiante.',
          tono: FeedbackTono.advertencia);
      return;
    }
    if (_fichaOrigen == null) {
      showFriendlySnack(context, 'Selecciona la ficha de origen.',
          tono: FeedbackTono.advertencia);
      return;
    }
    if (_fichaDestino == null) {
      showFriendlySnack(context, 'Selecciona la ficha de destino.',
          tono: FeedbackTono.advertencia);
      return;
    }
    if (_fichaOrigen!.id == _fichaDestino!.id) {
      showFriendlySnack(
        context,
        'Las fichas de origen y destino deben ser distintas.',
        tono: FeedbackTono.advertencia,
      );
      return;
    }

    final request = ReasignacionCreateRequest(
      estudianteId:   _estudiante!.id,
      fichaOrigenId:  _fichaOrigen!.id,
      fichaDestinoId: _fichaDestino!.id,
      motivo:         _motivoCtrl.text.trim(),
    );

    final provider = context.read<FichaProvider>();
    final result   = await provider.createReasignacion(request);

    if (!mounted) return;

    if (result != null) {
      Navigator.pop(context, true);
    } else {
      showFriendlyApiError(
        context,
        provider.mutationError,
        fallback: 'No se pudo crear la reasignación.',
      );
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
        title: const Text('NUEVA REASIGNACIÓN',
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                letterSpacing: 2)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.border),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _SectionLabel('Estudiante'),
            _PickerTile(
              label: _estudiante != null
                  ? (_estudiante!.nombreCompleto.isNotEmpty
                      ? _estudiante!.nombreCompleto
                      : '${_estudiante!.nombre} ${_estudiante!.apellido}')
                  : 'Seleccionar estudiante',
              icon:  Icons.person_outline,
              color: _estudiante != null ? AppTheme.primary : null,
              onTap: _pickEstudiante,
            ),
            const SizedBox(height: 20),

            _SectionLabel('Fichas'),
            _PickerTile(
              label: _fichaOrigen != null
                  ? '${_fichaOrigen!.codigoFicha} · ${_fichaOrigen!.programaNombre}'
                  : 'Ficha de origen',
              icon:  Icons.logout,
              color: _fichaOrigen != null ? AppTheme.textSecondary : null,
              onTap: () => _pickFicha(esOrigen: true),
            ),
            const SizedBox(height: 8),
            Center(
              child: Icon(Icons.arrow_downward,
                  color: AppTheme.primary.withOpacity(0.6), size: 22),
            ),
            const SizedBox(height: 8),
            _PickerTile(
              label: _fichaDestino != null
                  ? '${_fichaDestino!.codigoFicha} · ${_fichaDestino!.programaNombre}'
                  : 'Ficha de destino',
              icon:  Icons.login,
              color: _fichaDestino != null ? AppTheme.primary : null,
              onTap: () => _pickFicha(esOrigen: false),
            ),
            const SizedBox(height: 20),

            _SectionLabel('Motivo'),
            TextFormField(
              controller: _motivoCtrl,
              maxLines:   3,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                labelText: 'Descripción del motivo',
                alignLabelWithHint: true,
                labelStyle: TextStyle(
                    color: AppTheme.textSecondary.withOpacity(0.8)),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Campo requerido'
                  : null,
            ),
            const SizedBox(height: 32),

            ElevatedButton(
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
                  : const Text('Registrar reasignación',
                      style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── _SectionLabel ─────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String titulo;
  const _SectionLabel(this.titulo);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(titulo,
          style: const TextStyle(
              color: AppTheme.primary,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 2)),
    );
  }
}

// ── _PickerTile ────────────────────────────────────────────────────────────

class _PickerTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? color;
  final VoidCallback onTap;

  const _PickerTile({
    required this.label,
    required this.icon,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.textSecondary.withOpacity(0.5);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.surface.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.border.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Icon(icon, color: c, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      color: color != null
                          ? AppTheme.textPrimary
                          : AppTheme.textSecondary.withOpacity(0.5),
                      fontSize: 14)),
            ),
            Icon(Icons.chevron_right,
                color: AppTheme.textSecondary.withOpacity(0.4), size: 20),
          ],
        ),
      ),
    );
  }
}
