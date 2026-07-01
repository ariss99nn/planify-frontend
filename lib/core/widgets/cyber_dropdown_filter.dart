import 'package:flutter/material.dart';
import '../theme/theme.dart';

class CyberDropdownFilter<T> extends StatelessWidget {
  final String hint;
  final T? value;
  final List<(T, String)> items;
  final ValueChanged<T?> onChanged;
  final String allLabel;

  const CyberDropdownFilter({
    super.key,
    required this.hint,
    required this.items,
    required this.onChanged,
    this.value,
    this.allLabel = 'Todos',
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      hint: Text(hint,
          style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
      isDense: true,
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
      items: [
        DropdownMenuItem<T>(
          value: null,
          child: Text(allLabel,
              style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
        ),
        ...items.map(
          (e) => DropdownMenuItem<T>(
            value: e.$1,
            child: Text(e.$2, style: const TextStyle(fontSize: 13)),
          ),
        ),
      ],
      onChanged: onChanged,
    );
  }
}