import 'package:flutter/material.dart';

import '../../../core/constants/app_images.dart';
import '../../../core/theme/theme.dart';

class HomeBackground extends StatelessWidget {
  const HomeBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1000;
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              isDesktop ? AppImages.fondoWeb : AppImages.fondoApp,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: AppTheme.background.withOpacity(0.72),
            ),
          ),
        ],
      ),
    );
  }
}