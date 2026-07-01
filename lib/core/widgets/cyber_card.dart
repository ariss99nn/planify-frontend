import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/theme.dart';

class CyberCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  const CyberCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(28, 28, 28, 24),
    this.borderRadius = 24,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.surface.withOpacity(0.75),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: AppTheme.border, width: 1),
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}