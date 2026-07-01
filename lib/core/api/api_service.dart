import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../storage/token_storage.dart';

class ApiException implements Exception {
  final String message;
  final String? code;
  final int statusCode;

  ApiException({
    required this.message,
    required this.statusCode,
    this.code,
  });

  @override
  String toString() => 'ApiException($statusCode): $message [code: $code]';
}

class ApiService {
  static const String _defaultApiPath = '/api';

  static final String _environmentBaseUrl = const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );
  static String? _overrideBaseUrl;

  /// Hook opcional: se invoca cada vez que un refresh silencioso (401 →
  /// /auth/refresh/) obtiene un access token nuevo. Permite a otras capas
  /// (p.ej. AuthProvider) enterarse y propagar el token fresco a consumidores
  /// como el WebSocket de notificaciones.
  static void Function(String newAccessToken)? onTokenRefreshed;

  static void configure({String? baseUrl}) {
    if (baseUrl != null && baseUrl.isNotEmpty) {
      _overrideBaseUrl = _ensureApiPath(baseUrl);
    }
  }

  /// URL base con /api — usada para los endpoints de la API.
  static String get baseUrl {
    if (_overrideBaseUrl != null && _overrideBaseUrl!.isNotEmpty) {
      return _overrideBaseUrl!;
    }
    if (_environmentBaseUrl.isNotEmpty) {
      return _ensureApiPath(_environmentBaseUrl);
    }
    return _resolveBaseUrl();
  }

  /// URL del host sin /api — usada para construir URLs de archivos
  /// estáticos como imágenes en /media/.
  /// Ejemplo: "http://192.168.10.27:8000"
  static String get hostUrl {
    final uri = Uri.tryParse(baseUrl);
    if (uri == null) return baseUrl;
    return '${uri.scheme}://${uri.host}${uri.hasPort ? ':${uri.port}' : ''}';
  }

  /// Construye la URL absoluta de un archivo del servidor.
  /// Acepta rutas relativas como "media/usuarios/foto.jpg"
  /// o "/media/usuarios/foto.jpg" y devuelve la URL completa.
  /// Si ya es una URL absoluta, la retorna tal cual.
  static String? buildMediaUrl(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
    final path = raw.startsWith('/') ? raw : '/$raw';
    return '$hostUrl$path';
  }

  static String _resolveBaseUrl() {
    if (kIsWeb) {
      return 'http://localhost:8000$_defaultApiPath';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://192.168.10.27:8000$_defaultApiPath';
    }
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      return 'http://localhost:8000$_defaultApiPath';
    }
    return 'http://localhost:8000$_defaultApiPath';
  }

  static String _ensureApiPath(String url) {
    var normalized = url.trim();
    if (normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }
    if (normalized.endsWith(_defaultApiPath)) {
      return normalized;
    }
    return '$normalized$_defaultApiPath';
  }

  static Uri _buildUri(String endpoint, [Map<String, String>? queryParams]) {
    final normalizedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final normalizedEndpoint =
        endpoint.startsWith('/') ? endpoint : '/$endpoint';

    return Uri.parse('$normalizedBase$normalizedEndpoint').replace(
      queryParameters: queryParams?.isNotEmpty == true ? queryParams : null,
    );
  }

  static Map<String, String> _headers({String? token}) {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ── GET ──────────────────────────────────────────────────────────────────

  static Future<dynamic> get(
    String endpoint, {
    String? token,
    Map<String, String>? queryParams,
  }) async {
    final uri = _buildUri(endpoint, queryParams);
    final response = await http.get(uri, headers: _headers(token: token));

    if (response.statusCode == 401 && token != null) {
      return _retry((newToken) => http.get(
            uri,
            headers: _headers(token: newToken),
          ));
    }

    return _handle(response);
  }

  // ── POST ─────────────────────────────────────────────────────────────────

  static Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? data,
    String? token,
  }) async {
    final uri = _buildUri(endpoint);
    final body = jsonEncode(data);
    final response = await http.post(
      uri,
      headers: _headers(token: token),
      body: body,
    );

    if (response.statusCode == 401 && token != null) {
      return _retry((newToken) => http.post(
            uri,
            headers: _headers(token: newToken),
            body: body,
          ));
    }

    return _handle(response);
  }

  // ── PATCH ────────────────────────────────────────────────────────────────

  static Future<dynamic> patch(
    String endpoint, {
    Map<String, dynamic>? data,
    String? token,
  }) async {
    final uri = _buildUri(endpoint);
    final body = jsonEncode(data);
    final response = await http.patch(
      uri,
      headers: _headers(token: token),
      body: body,
    );

    if (response.statusCode == 401 && token != null) {
      return _retry((newToken) => http.patch(
            uri,
            headers: _headers(token: newToken),
            body: body,
          ));
    }

    return _handle(response);
  }

  // ── DELETE ───────────────────────────────────────────────────────────────

  static Future<dynamic> delete(String endpoint, {String? token}) async {
    final uri = _buildUri(endpoint);
    final response = await http.delete(uri, headers: _headers(token: token));

    if (response.statusCode == 401 && token != null) {
      return _retry((newToken) => http.delete(
            uri,
            headers: _headers(token: newToken),
          ));
    }

    return _handle(response);
    }

    static Future<Uint8List> downloadFile(
      String endpoint, {
      Map<String, dynamic>? data,
      String? token,
      Duration timeout = const Duration(seconds: 90),
    }) async {
      final uri  = _buildUri(endpoint);
      final body = jsonEncode(data);

      Future<http.Response> send(String? t) => http
          .post(uri, headers: _headers(token: t), body: body)
          .timeout(timeout);

      http.Response response;
      try {
        response = await send(token);
      } on TimeoutException {
        throw ApiException(
          message: 'El servidor tardó demasiado en responder. Intenta de nuevo.',
          statusCode: 408,
          code: 'timeout',
        );
      }

      if (response.statusCode == 401 && token != null) {
        final newToken = await _getNewToken();
        if (newToken == null) {
          throw ApiException(
            message: 'Sesión expirada. Inicia sesión nuevamente.',
            statusCode: 401,
            code: 'session_expired',
          );
        }
        try {
          response = await send(newToken);
        } on TimeoutException {
          throw ApiException(
            message: 'El servidor tardó demasiado en responder. Intenta de nuevo.',
            statusCode: 408,
            code: 'timeout',
          );
        }
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.bodyBytes;
      }

      final errorBody = _tryParseJson(response.body);
      throw ApiException(
        message: _extractMessage(errorBody),
        statusCode: response.statusCode,
        code: errorBody is Map ? errorBody['code'] as String? : null,
      );
    }

    static dynamic _tryParseJson(String body) {
      if (body.isEmpty) return null;
      try { return jsonDecode(body); } catch (_) { return null; }
    }

  // ── POST MULTIPART ───────────────────────────────────────────────────────

  static Future<dynamic> postMultipart(
    String endpoint, {
    Map<String, String>? fields,
    XFile? xfile,
    String? xfileField,
    String? token,
  }) async {
    final uri = _buildUri(endpoint);
    final request = http.MultipartRequest('POST', uri);

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    if (fields != null) request.fields.addAll(fields);

    if (xfile != null && xfileField != null) {
      final bytes = await xfile.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes(
        xfileField,
        bytes,
        filename: xfile.name,
      ));
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 401 && token != null) {
      final newToken = await _getNewToken();
      if (newToken != null) {
        return postMultipart(
          endpoint,
          fields: fields,
          xfile: xfile,
          xfileField: xfileField,
          token: newToken,
        );
      }
    }

    return _handle(response);
  }

  // ── PATCH MULTIPART ──────────────────────────────────────────────────────

  static Future<dynamic> patchMultipart(
    String endpoint, {
    Map<String, String>? fields,
    XFile? xfile,
    String? xfileField,
    String? token,
  }) async {
    final uri = _buildUri(endpoint);
    final request = http.MultipartRequest('PATCH', uri);

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    if (fields != null) request.fields.addAll(fields);

    if (xfile != null && xfileField != null) {
      final bytes = await xfile.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes(
        xfileField,
        bytes,
        filename: xfile.name,
      ));
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 401 && token != null) {
      final newToken = await _getNewToken();
      if (newToken != null) {
        return patchMultipart(
          endpoint,
          fields: fields,
          xfile: xfile,
          xfileField: xfileField,
          token: newToken,
        );
      }
    }

    return _handle(response);
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  static dynamic _handle(http.Response response) {
    final bodyString = response.body;

    if (bodyString.isEmpty) {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return null;
      }
      throw ApiException(
        message: 'Respuesta vacía del servidor',
        statusCode: response.statusCode,
      );
    }

    if (bodyString.trimLeft().startsWith('<')) {
      throw ApiException(
        message:
            'Respuesta inesperada del servidor: no es JSON. Verifica la URL o que el backend esté corriendo.',
        statusCode: response.statusCode,
      );
    }

    dynamic body;
    try {
      body = jsonDecode(bodyString);
    } catch (error) {
      throw ApiException(
        message:
            'Error al parsear JSON de respuesta: ${error.runtimeType}. Revisa la respuesta del servidor.',
        statusCode: response.statusCode,
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    final message = _extractMessage(body);
    final code = body is Map ? body['code'] as String? : null;

    throw ApiException(
      message: message,
      statusCode: response.statusCode,
      code: code,
    );
  }

  static String _extractMessage(dynamic body) {
    if (body == null) return 'Error desconocido';
    if (body is Map) {
      final detail = body['detail'];
      if (detail is String) return detail;
      if (detail is Map) return detail['detail'] as String? ?? 'Error';
      if (body.isNotEmpty) {
        final first = body.values.first;
        if (first is List && first.isNotEmpty) return first.first.toString();
      }
    }
    return 'Error desconocido';
  }

  static Future<dynamic> _retry(
    Future<http.Response> Function(String newToken) requestFn,
  ) async {
    final newToken = await _getNewToken();
    if (newToken == null) {
      throw ApiException(
        message: 'Sesión expirada. Inicia sesión nuevamente.',
        statusCode: 401,
        code: 'session_expired',
      );
    }

    final retryResponse = await requestFn(newToken);
    return _handle(retryResponse);
  }

  static Future<String?> _getNewToken() async {
    final refresh = await TokenStorage.getRefreshToken();

    if (refresh == null) {
      await TokenStorage.clear();
      return null;
    }

    final refreshResponse = await http.post(
      _buildUri('/auth/refresh/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh': refresh}),
    );

    if (refreshResponse.statusCode != 200) {
      await TokenStorage.clear();
      return null;
    }

    try {
      final data = jsonDecode(refreshResponse.body);
      final newAccess = data['access'] as String;

      // El backend usa ROTATE_REFRESH_TOKENS + BLACKLIST_AFTER_ROTATION:
      // cada refresh invalida el refresh token usado y devuelve uno nuevo.
      // Si no lo guardamos, el próximo refresh usará un token blacklisteado
      // y la sesión completa muere silenciosamente.
      final newRefresh = data['refresh'] as String? ?? refresh;

      await TokenStorage.saveTokens(newAccess, newRefresh);
      onTokenRefreshed?.call(newAccess);
      return newAccess;
    } catch (_) {
      await TokenStorage.clear();
      return null;
    }
  }
}