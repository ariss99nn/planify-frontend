import 'package:flutter/material.dart';
import '../theme/theme.dart';

class CyberIconHero extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final double size;

  const CyberIconHero({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.size = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withOpacity(0.25),
                blurRadius: 60,
                spreadRadius: 20,
              ),
            ],
            border: Border.all(
              color: AppTheme.primary.withOpacity(0.4),
              width: 1.5,
            ),
            color: AppTheme.surface.withOpacity(0.6),
          ),
          child: Icon(icon, size: size * 0.44, color: AppTheme.primary),
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