import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../constants/app_images.dart';

class CyberScaffold extends StatelessWidget {
  final Widget child;
  final bool showBackButton;

  const CyberScaffold({
    super.key,
    required this.child,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1000;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              isDesktop ? AppImages.fondoWeb : AppImages.fondoApp,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: AppTheme.background.withOpacity(0.78),
            ),
          ),
          SafeArea(
            child: showBackButton
                ? Stack(
                    children: [
                      child,
                      Positioned(
                        top: 8,
                        left: 8,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: AppTheme.primary,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  )
                : child,
          ),
        ],
      ),
    );
  }
}