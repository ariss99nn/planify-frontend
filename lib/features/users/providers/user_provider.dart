// lib/features/users/providers/user_provider.dart

import 'package:flutter/material.dart';
import '../../auth/models/user_model.dart';
import '../services/user_service.dart';

class UserProvider with ChangeNotifier {
  List<UserModel> users   = [];
  bool            loading = false;

  Future<void> fetchUsers({String? search}) async {
    loading = true;
    notifyListeners();

    try {
      final data = await UserService.getUsers(search: search);
      users = (data['results'] as List)
          .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      users = [];
    }

    loading = false;
    notifyListeners();
  }
}