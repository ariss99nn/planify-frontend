import 'package:flutter/material.dart';
import '../theme/theme.dart';

class CyberEmptyView extends StatelessWidget {
  final IconData icon;
  final String   title;
  /// Texto descriptivo. Alias de [subtitle] para compatibilidad.
  final String?  message;
  final String?  subtitle;
  final String?  actionLabel;
  final VoidCallback? onAction;

  const CyberEmptyView({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  String? get _body => message ?? subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: AppTheme.primary.withOpacity(0.35)),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.textSecondary.withOpacity(0.7),
                  ),
            ),
            if (_body != null) ...[
              const SizedBox(height: 6),
              Text(
                _body!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary.withOpacity(0.5),
                ),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add, size: 18),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
