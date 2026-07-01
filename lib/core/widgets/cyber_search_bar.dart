// lib/core/widgets/cyber_search_bar.dart

import 'package:flutter/material.dart';
import '../theme/theme.dart';

class CyberSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final String? hint;
  final ValueChanged<String?>? onSubmitted;
  final VoidCallback? onClear;
  final ValueChanged<String?>? onChanged;

  const CyberSearchBar({
    super.key,
    this.controller,
    this.hint,
    this.onSubmitted,
    this.onClear,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onSubmitted: (v) => onSubmitted?.call(v),
      onChanged: (v) => onChanged?.call(v),
      decoration: InputDecoration(
        hintText: hint ?? 'Buscar...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: onClear,
        ),
      ),
    );
  }
}