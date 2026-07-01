// lib/core/role_helper.dart

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../features/auth/providers/auth_provider.dart';
import 'constants/app_roles.dart';

bool isManagerRole(BuildContext context) {
  final rol = context.watch<AuthProvider>().user?.rol;
  return rol != null && AppRoles.managers.contains(rol);
}