import 'package:flutter/material.dart';
import '../theme/theme.dart';

class CyberHeroLogo extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final double imageSize;

  const CyberHeroLogo({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    this.imageSize = 120,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: imageSize,
          height: imageSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withOpacity(0.25),
                blurRadius: 60,
                spreadRadius: 20,
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.primary.withOpacity(0.4),
                width: 1.5,
              ),
              color: AppTheme.surface.withOpacity(0.6),
            ),
            padding: const EdgeInsets.all(12),
            child: Image.asset(imagePath, fit: BoxFit.contain),
          ),
        ),
        const SizedBox(height: 16),
        Text(title, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(letterSpacing: 0.4),
        ),
      ],
    );
  }
}