// lib/features/ficha/presentation/widgets/views/reasignacion_create_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/theme.dart';
import '../../../../../core/api/api_service.dart';
import '../../../../../core/models/paginated_response.dart';
import '../../providers/ficha_provider.dart';
import '../../../data/models/ficha_request_model.dart';
import '../../../data/repositories_impl/ficha_repository_impl.dart';
import '../../../domain/entities/ficha_entity.dart';
import '../../../domain/repositories/ficha_repository.dart';
import '../../../../auth/models/user_model.dart';
import '../ficha_pickers.dart';

class ReasignacionCreateView extends StatefulWidget {
  const ReasignacionCreateView({super.key});

  @override
  State<ReasignacionCreateView> createState() =>
      _ReasignacionCreateViewState();
}

class _ReasignacionCreateViewState extends State<ReasignacionCreateView> {
  final _formKey     = GlobalKey<FormState>();
  final _motivoCtrl  = TextEditingController();
  final _fichaRepo   = FichaRepositoryImpl();

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

  Future<void> _pickFicha({required bool esOrigen}) async {
    final picked = await showModalBottomSheet<FichaListEntity>(
      context: context,
      backgroundColor: AppTheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _FichaSearchSheet(
        fichaRepo: _fichaRepo,
        excluirId: esOrigen ? _fichaDestino?.id : _fichaOrigen?.id,
      ),
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
      _showSnack('Selecciona un estudiante.', isError: true);
      return;
    }
    if (_fichaOrigen == null) {
      _showSnack('Selecciona la ficha de origen.', isError: true);
      return;
    }
    if (_fichaDestino == null) {
      _showSnack('Selecciona la ficha de destino.', isError: true);
      return;
    }
    if (_fichaOrigen!.id == _fichaDestino!.id) {
      _showSnack('Las fichas de origen y destino deben ser distintas.',
          isError: true);
      return;
    }

    final request = ReasignacionCreateRequest(
      estudianteId:  _estudiante!.id,
      fichaOrigenId: _fichaOrigen!.id,
      fichaDestinoId: _fichaDestino!.id,
      motivo:        _motivoCtrl.text.trim(),
    );

    final provider = context.read<FichaProvider>();
    final result   = await provider.createReasignacion(request);

    if (!mounted) return;

    if (result != null) {
      Navigator.pop(context, true);
    } else {
      _showSnack(
          provider.mutationError ?? 'No se pudo crear la reasignación.',
          isError: true);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red.shade700 : AppTheme.primary,
      behavior: SnackBarBehavior.floating,
    ));
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

// ── _SectionLabel ──────────────────────────────────────────────────────────────

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

// ── _PickerTile ────────────────────────────────────────────────────────────────

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

// ── _FichaSearchSheet ──────────────────────────────────────────────────────────

class _FichaSearchSheet extends StatefulWidget {
  final FichaRepository fichaRepo;
  final int? excluirId;

  const _FichaSearchSheet({required this.fichaRepo, this.excluirId});

  @override
  State<_FichaSearchSheet> createState() => _FichaSearchSheetState();
}

class _FichaSearchSheetState extends State<_FichaSearchSheet> {
  final _searchCtrl  = TextEditingController();
  List<FichaListEntity> _resultados = [];
  bool   _cargando   = false;
  String _ultimaBusq = '';
  String? _error;

  @override
  void initState() {
    super.initState();
    _buscar('');
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _buscar(String query) async {
    if (query == _ultimaBusq && !_cargando && _error == null) return;
    _ultimaBusq = query;
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final PaginatedResponse<FichaListEntity> res =
          await widget.fichaRepo.getFichas(
        search:   query.isEmpty ? null : query,
        estado:   'ACTIVA',
        page:     1,
        pageSize: 15,
      );
      if (!mounted) return;
      setState(() {
        _resultados = res.results
            .where((f) => f.id != widget.excluirId)
            .toList();
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _resultados = [];
        _error = e.statusCode >= 500
            ? 'El servidor no pudo cargar las fichas (${e.statusCode}). '
                'Intenta de nuevo.'
            : e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _resultados = [];
        _error = 'No se pudo conectar con el servidor. Intenta de nuevo.';
      });
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize:     0.95,
      minChildSize:     0.5,
      expand:           false,
      builder: (_, scrollCtrl) => Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              autofocus:  true,
              style: const TextStyle(color: AppTheme.textPrimary),
              onChanged:  _buscar,
              decoration: InputDecoration(
                hintText: 'Buscar ficha activa…',
                hintStyle: TextStyle(
                    color: AppTheme.textSecondary.withOpacity(0.4)),
                prefixIcon:
                    const Icon(Icons.search, color: AppTheme.primary),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        BorderSide(color: AppTheme.border.withOpacity(0.5))),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ),
          Expanded(
            child: _cargando
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.error_outline,
                                  color: Colors.redAccent, size: 28),
                              const SizedBox(height: 10),
                              Text(_error!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      color: Colors.redAccent)),
                              const SizedBox(height: 14),
                              OutlinedButton.icon(
                                onPressed: () => _buscar(_ultimaBusq),
                                icon: const Icon(Icons.refresh, size: 18),
                                label: const Text('Reintentar'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.primary,
                                  side: BorderSide(color: AppTheme.primary),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _resultados.isEmpty
                    ? Center(
                        child: Text('Sin resultados',
                            style: TextStyle(
                                color:
                                    AppTheme.textSecondary.withOpacity(0.6))))
                    : ListView.builder(
                        controller:  scrollCtrl,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        itemCount:   _resultados.length,
                        itemBuilder: (_, i) {
                          final f = _resultados[i];
                          return ListTile(
                            onTap: () => Navigator.pop(context, f),
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color:
                                    AppTheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.folder_outlined,
                                  color: AppTheme.primary, size: 18),
                            ),
                            title: Text(f.codigoFicha,
                                style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14)),
                            subtitle: Text(
                              '${f.programaNombre} · ${f.jornadaDisplay}',
                              style: TextStyle(
                                  color:
                                      AppTheme.textSecondary.withOpacity(0.7),
                                  fontSize: 12),
                            ),
                            trailing: const Icon(Icons.chevron_right,
                                color: AppTheme.primary, size: 18),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
