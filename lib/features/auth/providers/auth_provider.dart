// lib/features/auth/providers/auth_provider.dart

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
import '../../../core/api/api_service.dart';
import '../../../core/storage/token_storage.dart';
import '../models/user_model.dart';

enum AuthStatus {
  checking,
  authenticated,
  unauthenticated,
  pendingVerification,
}

class AuthProvider with ChangeNotifier {
  AuthStatus _status      = AuthStatus.checking;
  UserModel? _user;
  String?    _pendingEmail;
  String?    _accessToken;

  AuthStatus get status        => _status;
  UserModel?  get user         => _user;
  String?     get pendingEmail => _pendingEmail;
  String?     get accessToken  => _accessToken;

  bool get isAuthenticated => _status == AuthStatus.authenticated;

  AuthProvider() {
    // Se entera cuando ApiService renueva el access token de forma
    // silenciosa (401 → /auth/refresh/), y propaga el token fresco a
    // través de notifyListeners() para que el ChangeNotifierProxyProvider
    // de NotificacionesProvider reconecte el WS con el token correcto.
    ApiService.onTokenRefreshed = _onTokenRefreshedSilently;
  }

  void _onTokenRefreshedSilently(String newAccessToken) {
    _accessToken = newAccessToken;
    notifyListeners();
  }

  Future<void> checkAuth() async {
    _status = AuthStatus.checking;
    notifyListeners();

    try {
      final token = await TokenStorage.getAccessToken();
      if (token == null) {
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return;
      }

      final userData = await AuthService.getProfile(token);
      _user        = UserModel.fromJson(userData);
      _status      = AuthStatus.authenticated;
      _accessToken = token;
    } on ApiException catch (e) {
      if (e.code == 'session_expired') {
        await _clearSession();
        return;
      } else {
        _setUnauthenticated();
      }
    } catch (_) {
      _setUnauthenticated();
    }

    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    final res = await AuthService.login(email: email, password: password);

    final access   = res['access']  as String?;
    final refresh  = res['refresh'] as String?;
    final userData = res['user']    as Map<String, dynamic>?;

    if (access == null || refresh == null || userData == null) {
      throw ApiException(
        message: 'Respuesta inválida del servidor.',
        statusCode: 200,
      );
    }

    await TokenStorage.saveTokens(access, refresh);

    _user         = UserModel.fromJson(userData);
    _status       = AuthStatus.authenticated;
    _accessToken  = access;
    _pendingEmail = null;

    notifyListeners();
  }

  Future<void> register({
    required String nombre,
    required String apellido,
    required String email,
    required String password,
    required String password2,
    XFile? imagen,
  }) async {
    await AuthService.register(
      nombre:    nombre,
      apellido:  apellido,
      email:     email,
      password:  password,
      password2: password2,
      imagen:    imagen,
    );

    _pendingEmail = email.trim().toLowerCase();
    _status       = AuthStatus.pendingVerification;
    notifyListeners();
  }

  Future<void> verifyEmail({
    required String email,
    required String code,
  }) async {
    await AuthService.verifyEmail(email: email, code: code);
    _pendingEmail = null;
    _status       = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> resendVerification(String email) async {
    await AuthService.resendVerification(email);
  }

  Future<void> logout() async {
    try {
      final refresh = await TokenStorage.getRefreshToken();
      final access  = _accessToken ?? await TokenStorage.getAccessToken();
      if (refresh != null && access != null) {
        await AuthService.logout(
          refreshToken: refresh,
          accessToken:  access,
        );
      }
    } catch (_) {}

    await _clearSession();
  }

  void updateLocalUser(UserModel updated) {
    _user = updated;
    notifyListeners();
  }

  Future<void> updateProfile({
    String? nombre,
    String? apellido,
    XFile?  imagen,
    bool    eliminarImagen = false,
  }) async {
    final token = _accessToken ?? await TokenStorage.getAccessToken();
    if (token == null) {
      throw ApiException(
        message: 'Sesión expirada.',
        statusCode: 401,
        code: 'session_expired',
      );
    }

    final updated = await AuthService.updateProfileWithImage(
      token:          token,
      nombre:         nombre,
      apellido:       apellido,
      imagen:         imagen,
      eliminarImagen: eliminarImagen,
    );

    _user = UserModel.fromJson(updated);
    notifyListeners();
  }

  Future<void> requestEmailChange(String newEmail) async {
    final token = _accessToken ?? await TokenStorage.getAccessToken();
    if (token == null) {
      throw ApiException(
        message: 'Sesión expirada.',
        statusCode: 401,
        code: 'session_expired',
      );
    }
    await AuthService.requestEmailChange(token: token, newEmail: newEmail);
  }

  Future<void> confirmEmailChange(String code) async {
    final token = _accessToken ?? await TokenStorage.getAccessToken();
    if (token == null) {
      throw ApiException(
        message: 'Sesión expirada.',
        statusCode: 401,
        code: 'session_expired',
      );
    }
    await AuthService.confirmEmailChange(token: token, code: code);

    final userData = await AuthService.getProfile(token);
    _user = UserModel.fromJson(userData);
    notifyListeners();
  }

  void _setUnauthenticated() {
    _user        = null;
    _status      = AuthStatus.unauthenticated;
    _accessToken = null;
  }

  Future<void> _clearSession() async {
    await TokenStorage.clear();
    _setUnauthenticated();
    notifyListeners();
  }

  String? get nombre    => _user?.nombre;
  String? get apellido  => _user?.apellido;
  String? get email     => _user?.email;
  String? get rol       => _user?.rol;
  String? get imagenUrl => _user?.imagenUrl;
  bool get emailVerificado        => _user?.emailVerificado ?? false;
  bool get puedeGestionarUsuarios => _user?.puedeGestionarUsuarios ?? false;
}