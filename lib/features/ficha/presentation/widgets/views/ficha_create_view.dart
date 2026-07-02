// lib/features/ficha/presentation/widgets/views/ficha_create_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/theme.dart';
import '../../providers/ficha_provider.dart';
import '../../../data/models/ficha_request_model.dart';
import '../../../../programa/domain/entities/version_programa_entity.dart';
import '../../../../docentes/domain/entities/docente_entity.dart';
import '../ficha_form_fields.dart';
import '../ficha_pickers.dart';

class FichaCreateView extends StatefulWidget {
  const FichaCreateView({super.key});

  @override
  State<FichaCreateView> createState() => _FichaCreateViewState();
}

class _FichaCreateViewState extends State<FichaCreateView> {
  final _formKey         = GlobalKey<FormState>();
  final _codigoCtrl      = TextEditingController();
  final _estudiantesCtrl = TextEditingController();

  String    _jornada         = 'MANANA';
  String    _etapa           = 'LECTIVA';
  String    _estado          = 'ACTIVA';
  bool      _cadenaFormacion = false;
  DateTime? _fechaInicio;

  VersionResumenEntity? _version;
  DocenteEntity?         _jefeGrupo;

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
    _estudiantesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFechaInicio() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaInicio ?? DateTime.now(),
      firstDate: DateTime(2015),
      lastDate:  DateTime(2035),
    );
    if (picked == null) return;
    setState(() => _fechaInicio = picked);
  }

  String _fmtFecha(DateTime? d) {
    if (d == null) return 'Hoy (por defecto)';
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  Future<void> _pickVersion() async {
    final picked = await pickVersionPrograma(context);
    if (picked == null) return;
    setState(() => _version = picked);
  }

  Future<void> _pickJefeGrupo() async {
    final picked = await pickDocente(context);
    if (picked == null) return;
    setState(() => _jefeGrupo = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_version == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Selecciona el programa (versión) de la ficha.'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    final request = FichaCreateRequest(
      codigoFicha:               _codigoCtrl.text.trim(),
      versionId:                 _version!.id,
      jornada:                   _jornada,
      numeroEstudiantesEstimado: int.parse(_estudiantesCtrl.text.trim()),
      etapa:                     _etapa,
      estado:                    _estado,
      cadenaFormacion:           _cadenaFormacion,
      jefeGrupoId:               _jefeGrupo?.id,
      fechaInicio:               _fechaInicio,
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
            FichaPickerTile(
              label: _version != null
                  ? '${_version!.programaNombre} · v${_version!.numero}'
                  : 'Seleccionar programa',
              icon: Icons.menu_book_outlined,
              tieneValor: _version != null,
              onTap: _pickVersion,
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
            TextFormField(
              controller: _estudiantesCtrl,
              keyboardType: TextInputType.number,
              enabled: !_cadenaFormacion,
              style: TextStyle(
                  color: _cadenaFormacion
                      ? AppTheme.textSecondary
                      : AppTheme.textPrimary),
              decoration: _dec('Cupo estimado', icon: Icons.people_outline)
                  .copyWith(
                helperText: _cadenaFormacion
                    ? 'En cadena de formación el cupo se gestiona por '
                        'trimestre, no aquí.'
                    : null,
              ),
              validator: (v) {
                if (_cadenaFormacion) return null;
                final n = int.tryParse(v?.trim() ?? '');
                if (n == null || n <= 0) return '> 0';
                return null;
              },
            ),
            const SizedBox(height: 10),
            Text(
              'Las horas/semana y la fecha fin estimada se calculan '
              'automáticamente a partir de las horas del programa y su '
              'nivel de formación.',
              style: TextStyle(
                  color: AppTheme.textSecondary.withOpacity(0.6),
                  fontSize: 11),
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
                  'Solo se define aquí; no podrá cambiarse después de crear '
                  'la ficha. El programa debe tener trimestres de cadena '
                  'configurados.',
                  style: TextStyle(
                      color: AppTheme.textSecondary.withOpacity(0.6),
                      fontSize: 11),
                ),
                value: _cadenaFormacion,
                onChanged: (v) => setState(() {
                  _cadenaFormacion = v;
                  // Para esta modalidad el cupo lo gestiona el backend por
                  // trimestre: el campo se bloquea y se envía en 0.
                  if (v) {
                    _estudiantesCtrl.text = '0';
                  } else if (_estudiantesCtrl.text.trim() == '0') {
                    _estudiantesCtrl.text = '';
                  }
                }),
              ),
            ),
            const SizedBox(height: 24),

            const FichaSeccionLabel('Jefe de grupo (opcional)'),
            FichaPickerTile(
              label: _jefeGrupo?.nombre ?? 'Seleccionar docente',
              icon: Icons.person_outline,
              tieneValor: _jefeGrupo != null,
              onTap: _pickJefeGrupo,
            ),
            const SizedBox(height: 24),

            const FichaSeccionLabel('Fechas'),
            FichaFechaTile(
              label: 'Inicio',
              value: _fmtFecha(_fechaInicio),
              onTap: _pickFechaInicio,
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
