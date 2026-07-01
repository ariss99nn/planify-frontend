import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';

/// Bottom nav exclusivo para rol ESTUDIANTE (Inicio / Horarios / Asistente).
class HomeBottomNav extends StatelessWidget {
  final int              currentIndex;
  final ValueChanged<int> onTap;

  const HomeBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0C1E29),
        border: Border(top: BorderSide(color: AppTheme.border, width: 0.5)),
      ),
      child: BottomNavigationBar(
        currentIndex:        currentIndex.clamp(0, 2),
        selectedItemColor:   AppTheme.primary,
        unselectedItemColor: AppTheme.textSecondary,
        backgroundColor:     Colors.transparent,
        elevation:           0,
        onTap:               onTap,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded), label: 'Inicio'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month), label: 'Horarios'),
          BottomNavigationBarItem(
              icon: Icon(Icons.smart_toy_outlined), label: 'Asistente'),
        ],
      ),
    );
  }
}