import 'package:flutter/material.dart';
import 'cyber_button.dart';

class CyberErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final String retryLabel;

  const CyberErrorView({
    super.key,
    required this.message,
    required this.onRetry,
    this.retryLabel = 'Reintentar',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                size: 48, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 20),
            CyberButton(label: retryLabel, onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}