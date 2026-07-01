// lib/features/ficha/presentation/widgets/views/ficha_create_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/theme.dart';
import '../../providers/ficha_provider.dart';
import '../../../data/models/ficha_request_model.dart';
import '../ficha_form_fields.dart';

class FichaCreateView extends StatefulWidget {
  const FichaCreateView({super.key});

  @override
  State<FichaCreateView> createState() => _FichaCreateViewState();
}

class _FichaCreateViewState extends State<FichaCreateView> {
  final _formKey          = GlobalKey<FormState>();
  final _codigoCtrl       = TextEditingController();
  final _versionIdCtrl    = TextEditingController();
  final _estudiantesCtrl  = TextEditingController();
  final _horasCtrl        = TextEditingController();
  final _trimestreCtrl    = TextEditingController(text: '1');
  final _jefeGrupoIdCtrl  = TextEditingController();

  String    _jornada         = 'MANANA';
  String    _etapa           = 'LECTIVA';
  String    _estado          = 'ACTIVA';
  bool      _cadenaFormacion = false;
  DateTime? _fechaInicio;
  DateTime? _fechaFinalizacion;

  static const _jornadas = {
    'MANANA': 'Mañana', 'TARDE': 'Tarde', 'NOCHE': 'Noche', 'MIXTA': 'Mixta',
  };
  static const _etapas  = {'LECTIVA': 'Lectiva', 'PRODUCTIVA': 'Productiva'};
  static const _estados = {
    'ACTIVA': 'Activa', 'INACTIVA': 'Inactiva', 'CERRADA': 'Cerrada',
  };

  @override
  void dispose() {
    _codigoCtrl.dispose();
    _versionIdCtrl.dispose();
    _estudiantesCtrl.dispose();
    _horasCtrl.dispose();
    _trimestreCtrl.dispose();
    _jefeGrupoIdCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFecha({required bool esInicio}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: esInicio
          ? (_fechaInicio ?? DateTime.now())
          : (_fechaFinalizacion ?? (_fechaInicio ?? DateTime.now())),
      firstDate: DateTime(2015),
      lastDate:  DateTime(2035),
    );
    if (picked == null) return;
    setState(() {
      if (esInicio) {
        _fechaInicio = picked;
      } else {
        _fechaFinalizacion = picked;
      }
    });
  }

  String _fmtFecha(DateTime? d) {
    if (d == null) return 'Seleccionar fecha';
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_fechaInicio == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Selecciona la fecha de inicio.'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    if (_fechaFinalizacion != null &&
        _fechaFinalizacion!.isBefore(_fechaInicio!)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('La fecha de finalización no puede ser anterior al inicio.'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    final request = FichaCreateRequest(
      codigoFicha:               _codigoCtrl.text.trim(),
      versionId:                 int.parse(_versionIdCtrl.text.trim()),
      jornada:                   _jornada,
      numeroEstudiantesEstimado: int.parse(_estudiantesCtrl.text.trim()),
      etapa:                     _etapa,
      horasSemanalesObjetivo:    int.parse(_horasCtrl.text.trim()),
      trimestre:                 int.parse(_trimestreCtrl.text.trim()),
      estado:                    _estado,
      cadenaFormacion:           _cadenaFormacion,
      jefeGrupoId:               _jefeGrupoIdCtrl.text.trim().isEmpty
          ? null
          : int.parse(_jefeGrupoIdCtrl.text.trim()),
      fechaInicio:               _fechaInicio!,
      fechaFinalizacion:         _fechaFinalizacion,
    );

    final provider = context.read<FichaProvider>();
    final ficha    = await provider.createFicha(request);

    if (!mounted) return;

    if (ficha != null) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(provider.mutationError ?? 'No se pudo crear la ficha.'),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  InputDecoration _dec(String label, {String? hint, IconData? icon}) =>
      InputDecoration(
        labelText: label,
        hintText:  hint,
        prefixIcon: icon != null ? Icon(icon, color: AppTheme.primary) : null,
        labelStyle: TextStyle(color: AppTheme.textSecondary.withOpacity(0.8)),
      );

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<FichaProvider>().loadingMutation;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        title: const Text('NUEVA FICHA',
            style: TextStyle(
                fontWeight: FontWeight.w700, fontSize: 16, letterSpacing: 2)),
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
            const FichaSeccionLabel('Identificación'),
            TextFormField(
              controller: _codigoCtrl,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: _dec('Código de ficha', icon: Icons.tag),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _versionIdCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: _dec('ID de versión del programa',
                  icon: Icons.menu_book_outlined,
                  hint: 'Selector visual pendiente (módulo programa)'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Campo requerido';
                if (int.tryParse(v.trim()) == null) return 'Debe ser numérico';
                return null;
              },
            ),
            const SizedBox(height: 24),

            const FichaSeccionLabel('Configuración'),
            FichaDropdownField(
              label:     'Jornada',
              value:     _jornada,
              opciones:  _jornadas,
              onChanged: (v) => setState(() => _jornada = v!),
            ),
            const SizedBox(height: 14),
            FichaDropdownField(
              label:     'Etapa inicial',
              value:     _etapa,
              opciones:  _etapas,
              onChanged: (v) => setState(() => _etapa = v!),
            ),
            const SizedBox(height: 14),
            FichaDropdownField(
              label:     'Estado',
              value:     _estado,
              opciones:  _estados,
              onChanged: (v) => setState(() => _estado = v!),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _estudiantesCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: _dec('Cupo estimado', icon: Icons.people_outline),
                    validator: (v) {
                      final n = int.tryParse(v?.trim() ?? '');
                      if (n == null || n <= 0) return '> 0';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _horasCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: _dec('Horas/semana', icon: Icons.schedule),
                    validator: (v) {
                      final n = int.tryParse(v?.trim() ?? '');
                      if (n == null || n <= 0) return '> 0';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _trimestreCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration:
                  _dec('Trimestre inicial', icon: Icons.calendar_view_month),
              validator: (v) {
                final n = int.tryParse(v?.trim() ?? '');
                if (n == null || n < 1) return 'Debe ser ≥ 1';
                return null;
              },
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.border.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: AppTheme.accent,
                title: const Text('Cadena de formación',
                    style:
                        TextStyle(color: AppTheme.textPrimary, fontSize: 14)),
                subtitle: Text(
                  'El programa debe tener trimestres de cadena configurados.',
                  style: TextStyle(
                      color: AppTheme.textSecondary.withOpacity(0.6),
                      fontSize: 11),
                ),
                value:     _cadenaFormacion,
                onChanged: (v) => setState(() => _cadenaFormacion = v),
              ),
            ),
            const SizedBox(height: 24),

            const FichaSeccionLabel('Jefe de grupo (opcional)'),
            TextFormField(
              controller: _jefeGrupoIdCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: _dec('ID del docente',
                  icon: Icons.person_outline,
                  hint: 'Selector visual pendiente (módulo docentes)'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                if (int.tryParse(v.trim()) == null) return 'Debe ser numérico';
                return null;
              },
            ),
            const SizedBox(height: 24),

            const FichaSeccionLabel('Fechas'),
            Row(
              children: [
                Expanded(
                  child: FichaFechaTile(
                    label: 'Inicio',
                    value: _fmtFecha(_fechaInicio),
                    onTap: () => _pickFecha(esInicio: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FichaFechaTile(
                    label: 'Fin estimado',
                    value: _fmtFecha(_fechaFinalizacion),
                    onTap: () => _pickFecha(esInicio: false),
                  ),
                ),
              ],
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
                  : const Text('Crear ficha',
                      style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}
