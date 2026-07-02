// lib/features/ficha/presentation/widgets/ficha_pickers.dart
//
// Selectores visuales por nombre (docente, programa/versión, estudiante)
// que reemplazan los antiguos campos de "ID numérico" en los formularios
// de ficha, manteniendo el mismo patrón visual de búsqueda ya usado en
// la reasignación de fichas.

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/api/api_service.dart';
import '../../../auth/models/user_model.dart';
import '../../../users/services/user_service.dart';
import '../../../docentes/domain/entities/docente_entity.dart';
import '../../../docentes/data/repositories_impl/docente_repository_impl.dart';
import '../../../programa/domain/entities/version_programa_entity.dart';
import '../../../programa/data/repositories_impl/version_repository_impl.dart';

// ── Tile reutilizable para abrir un selector ────────────────────────────────

class FichaPickerTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool tieneValor;
  final VoidCallback onTap;
  final bool enabled;

  const FichaPickerTile({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.tieneValor = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final c = !enabled
        ? AppTheme.textSecondary.withOpacity(0.3)
        : (tieneValor ? AppTheme.primary : AppTheme.textSecondary.withOpacity(0.5));
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
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
              child: Text(
                label,
                style: TextStyle(
                  color: (enabled && tieneValor)
                      ? AppTheme.textPrimary
                      : AppTheme.textSecondary.withOpacity(0.5),
                  fontSize: 14,
                ),
              ),
            ),
            if (enabled)
              Icon(Icons.chevron_right,
                  color: AppTheme.textSecondary.withOpacity(0.4), size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Hoja de búsqueda genérica ───────────────────────────────────────────────

class _SearchSheet<T> extends StatefulWidget {
  final String hint;
  final Future<List<T>> Function(String query) buscar;
  final Widget Function(T item) itemBuilder;

  const _SearchSheet({
    required this.hint,
    required this.buscar,
    required this.itemBuilder,
  });

  @override
  State<_SearchSheet<T>> createState() => _SearchSheetState<T>();
}

class _SearchSheetState<T> extends State<_SearchSheet<T>> {
  final _searchCtrl = TextEditingController();
  List<T> _resultados = [];
  bool _cargando = false;
  String? _error;
  String _ultimaBusq = '';

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
    _ultimaBusq = query;
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final res = await widget.buscar(query);
      if (!mounted) return;
      setState(() => _resultados = res);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _resultados = [];
        _error = e.statusCode >= 500
            ? 'El servidor no pudo procesar la búsqueda (${e.statusCode}). '
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
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (_, scrollCtrl) => Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: AppTheme.border, borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              autofocus: true,
              style: const TextStyle(color: AppTheme.textPrimary),
              onChanged: _buscar,
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle:
                    TextStyle(color: AppTheme.textSecondary.withOpacity(0.4)),
                prefixIcon: const Icon(Icons.search, color: AppTheme.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppTheme.border.withOpacity(0.5)),
                ),
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
                                color: AppTheme.textSecondary.withOpacity(0.6))))
                    : ListView.builder(
                        controller: scrollCtrl,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        itemCount: _resultados.length,
                        itemBuilder: (_, i) => InkWell(
                          onTap: () => Navigator.pop(context, _resultados[i]),
                          child: widget.itemBuilder(_resultados[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

Widget _tileRow({
  required IconData icon,
  required String titulo,
  required String subtitulo,
}) {
  return ListTile(
    leading: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: AppTheme.primary, size: 18),
    ),
    title: Text(titulo,
        style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 14)),
    subtitle: Text(subtitulo,
        style: TextStyle(
            color: AppTheme.textSecondary.withOpacity(0.7), fontSize: 12)),
    trailing: const Icon(Icons.chevron_right, color: AppTheme.primary, size: 18),
  );
}

// ── Selector de docente (jefe de grupo) ─────────────────────────────────────

Future<DocenteEntity?> pickDocente(BuildContext context) {
  final repo = DocenteRepositoryImpl();
  return showModalBottomSheet<DocenteEntity>(
    context: context,
    backgroundColor: AppTheme.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => _SearchSheet<DocenteEntity>(
      hint: 'Buscar docente por nombre…',
      buscar: (query) async {
        final res = await repo.getDocentes(
          search: query.isEmpty ? null : query,
          estado: true,
          page: 1,
        );
        return res.results;
      },
      itemBuilder: (d) => _tileRow(
        icon: Icons.person_outline,
        titulo: d.nombre,
        subtitulo: '${d.especialidad} · ${d.email}',
      ),
    ),
  );
}

// ── Selector de programa / versión ──────────────────────────────────────────

Future<VersionResumenEntity?> pickVersionPrograma(BuildContext context) {
  final repo = VersionRepositoryImpl();
  return showModalBottomSheet<VersionResumenEntity>(
    context: context,
    backgroundColor: AppTheme.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => _SearchSheet<VersionResumenEntity>(
      hint: 'Buscar programa…',
      buscar: (query) async {
        final res = await repo.list(
          search: query.isEmpty ? null : query,
          vigente: true,
          pageSize: 15,
        );
        return res.results;
      },
      itemBuilder: (v) => _tileRow(
        icon: Icons.menu_book_outlined,
        titulo: v.programaNombre,
        subtitulo: 'v${v.numero} · ${v.totalHoras}h totales',
      ),
    ),
  );
}

// ── Selector de estudiante ──────────────────────────────────────────────────

Future<UserModel?> pickEstudiante(BuildContext context) {
  return showModalBottomSheet<UserModel>(
    context: context,
    backgroundColor: AppTheme.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => _SearchSheet<UserModel>(
      hint: 'Buscar estudiante por nombre…',
      buscar: (query) async {
        final data = await UserService.getUsersEstudiantes(
          search: query.isEmpty ? null : query,
        );
        final results = (data['results'] as List? ?? []);
        return results
            .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
      itemBuilder: (u) => _tileRow(
        icon: Icons.school_outlined,
        titulo: u.nombreCompleto.isNotEmpty
            ? u.nombreCompleto
            : '${u.nombre} ${u.apellido}',
        subtitulo: u.email,
      ),
    ),
  );
}
