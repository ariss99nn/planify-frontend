import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_images.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../auth/providers/auth_provider.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color:       AppTheme.primary.withOpacity(0.2),
                    blurRadius:  80,
                    spreadRadius: 20,
                  ),
                ],
              ),
              child: Image.asset(
                AppImages.logoApp,
                height: 180,
                fit:    BoxFit.contain,
              ),
            ),
            const SizedBox(height: 36),
            Text('Bienvenido,',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text(
              user.nombreCompleto,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontSize: 26),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            CyberInfoRow(
              icon: Icons.email_outlined,
              text: user.email,
            ),
          ],
        ),
      ),
    );
  }
}