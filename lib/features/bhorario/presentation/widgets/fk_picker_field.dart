// lib/features/bhorario/presentation/widgets/fk_picker_field.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../data/models/fk_option_model.dart';

// ── Widget público ─────────────────────────────────────────────────────────

/// Campo de formulario que abre un bottom sheet de búsqueda para elegir
/// una entidad FK.  Lazy-load: la lista se carga solo al abrir el picker.
class FkPickerField extends StatelessWidget {
  final FkOption?                           value;
  final IconData                            icon;
  final String                              label;
  final String                              placeholder;
  final Future<List<FkOption>> Function()   fetchOptions;
  final void Function(FkOption?)            onChanged;

  const FkPickerField({
    super.key,
    required this.value,
    required this.icon,
    required this.label,
    required this.placeholder,
    required this.fetchOptions,
    required this.onChanged,
  });

  void _openPicker(BuildContext context) {
    showModalBottomSheet(
      context:            context,
      isScrollControlled: true,
      backgroundColor:    Colors.transparent,
      builder: (_) => _FkSearchSheet(
        title:        label,
        fetchOptions: fetchOptions,
        selected:     value,
        onSelect: (opt) {
          Navigator.pop(context);
          onChanged(opt);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null;
    final activeColor = hasValue ? AppTheme.primary : AppTheme.textSecondary;

    return GestureDetector(
      onTap: () => _openPicker(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color:        AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasValue ? AppTheme.primary : AppTheme.border,
            width: hasValue ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: activeColor),
            const SizedBox(width: 12),
            Expanded(
              child: hasValue
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize:       MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            color:    AppTheme.primary,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          value!.display,
                          style: const TextStyle(
                            color:      AppTheme.textPrimary,
                            fontSize:   14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (value!.subtitle != null)
                          Text(
                            value!.subtitle!,
                            style: const TextStyle(
                              color:    AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    )
                  : Text(
                      placeholder,
                      style: const TextStyle(
                        color:    AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
            ),
            if (hasValue)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap:    () => onChanged(null),
                child: const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.close_rounded,
                    size:  18,
                    color: AppTheme.textSecondary,
                  ),
                ),
              )
            else
              const Icon(
                Icons.search_rounded,
                size:  18,
                color: AppTheme.textSecondary,
              ),
          ],
        ),
      ),
    );
  }
}

// ── Bottom sheet de búsqueda ────────────────────────────────────────────────

class _FkSearchSheet extends StatefulWidget {
  final String                            title;
  final Future<List<FkOption>> Function() fetchOptions;
  final FkOption?                         selected;
  final void Function(FkOption)           onSelect;

  const _FkSearchSheet({
    required this.title,
    required this.fetchOptions,
    required this.selected,
    required this.onSelect,
  });

  @override
  State<_FkSearchSheet> createState() => _FkSearchSheetState();
}

class _FkSearchSheetState extends State<_FkSearchSheet> {
  final _searchCtrl = TextEditingController();
  final _focusNode  = FocusNode();

  bool             _loading  = true;
  String?          _error;
  List<FkOption>   _all      = [];
  List<FkOption>   _filtered = [];

  @override
  void initState() {
    super.initState();
    _load();
    _searchCtrl.addListener(_filter);
    // Auto-focus search field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final opts = await widget.fetchOptions();
      if (!mounted) return;
      setState(() {
        _all      = opts;
        _filtered = opts;
        _loading  = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error   = 'No se pudo cargar la lista';
        _loading = false;
      });
    }
  }

  void _filter() {
    final q = _searchCtrl.text.toLowerCase().trim();
    setState(() {
      _filtered = q.isEmpty
          ? _all
          : _all.where((o) {
              return o.display.toLowerCase().contains(q) ||
                     (o.subtitle?.toLowerCase().contains(q) ?? false);
            }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize:     0.5,
      maxChildSize:     0.95,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color:        AppTheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // Handle
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color:        AppTheme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Título
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
              child: Row(
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color:      AppTheme.textPrimary,
                      fontSize:   18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (!_loading)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        '(${_filtered.length})',
                        style: const TextStyle(
                          color:    AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Buscador
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: TextField(
                controller:  _searchCtrl,
                focusNode:   _focusNode,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search_rounded, size: 20),
                  hintText:   'Buscar…',
                  isDense:    true,
                ),
              ),
            ),

            const Divider(color: AppTheme.border, height: 1),

            // Contenido
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppTheme.primary),
                    )
                  : _error != null
                      ? _ErrorRetry(
                          mensaje: _error!,
                          onRetry: () {
                            setState(() {
                              _loading = true;
                              _error   = null;
                            });
                            _load();
                          },
                        )
                  : _filtered.isEmpty
                      ? const Center(
                          child: Text(
                            'Sin resultados',
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                        )
                      : ListView.separated(
                          controller:      ctrl,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount:       _filtered.length,
                          separatorBuilder: (_, __) => const Divider(
                            color: AppTheme.border,
                            height: 1,
                            indent: 56,
                          ),
                          itemBuilder: (_, i) {
                            final opt      = _filtered[i];
                            final isSelected =
                                widget.selected?.id == opt.id;
                            return ListTile(
                              leading: Container(
                                width: 36, height: 36,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.primary.withOpacity(0.15)
                                      : AppTheme.surfaceLight,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? AppTheme.primary
                                        : AppTheme.border,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '${opt.id}',
                                    style: TextStyle(
                                      color: isSelected
                                          ? AppTheme.primary
                                          : AppTheme.textSecondary,
                                      fontSize:   11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(
                                opt.display,
                                style: TextStyle(
                                  color: isSelected
                                      ? AppTheme.primary
                                      : AppTheme.textPrimary,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              subtitle: opt.subtitle != null
                                  ? Text(
                                      opt.subtitle!,
                                      style: const TextStyle(
                                        color:    AppTheme.textSecondary,
                                        fontSize: 12,
                                      ),
                                    )
                                  : null,
                              trailing: isSelected
                                  ? const Icon(Icons.check_circle_rounded,
                                      color: AppTheme.primary, size: 20)
                                  : null,
                              onTap: () => widget.onSelect(opt),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  final String       mensaje;
  final VoidCallback onRetry;
  const _ErrorRetry({required this.mensaje, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded,
                color: AppTheme.textSecondary, size: 40),
            const SizedBox(height: 12),
            Text(mensaje,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 14)),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon:      const Icon(Icons.refresh_rounded),
              label:     const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}