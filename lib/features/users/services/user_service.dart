// lib/features/users/services/user_service.dart

import 'package:image_picker/image_picker.dart';
import '../../../core/api/api_service.dart';
import '../../../core/storage/token_storage.dart';

class UserService {
  static Future<dynamic> getUsers({String? search}) async {
    final token = await TokenStorage.getAccessToken();
    return ApiService.get(
      '/users/?search=${search ?? ''}',
      token: token,
    );
  }

  static Future<dynamic> getUser(int id) async {
    final token = await TokenStorage.getAccessToken();
    return ApiService.get('/users/$id/', token: token);
  }

  static Future<dynamic> createUser({
    required String nombre,
    required String apellido,
    required String email,
    required String password,
    required String rol,
    XFile?          imagen,
  }) async {
    final token = await TokenStorage.getAccessToken();
    return ApiService.postMultipart(
      '/users/',
      token: token,
      fields: {
        'nombre':    nombre.trim(),
        'apellido':  apellido.trim(),
        'email':     email.trim().toLowerCase(),
        'password':  password,
        'password2': password,
        'rol':       rol,
      },
      xfile:      imagen,
      xfileField: 'imagen',
    );
  }

  static Future<dynamic> updateUser({
    required int                  id,
    required Map<String, dynamic> data,
    XFile?                        imagen,
    bool                          eliminarImagen = false,
  }) async {
    final token = await TokenStorage.getAccessToken();

    if (imagen != null || eliminarImagen) {
      final fields = data.map((k, v) => MapEntry(k, v.toString()));
      if (eliminarImagen && imagen == null) fields['imagen'] = '';
      return ApiService.patchMultipart(
        '/users/$id/',
        token:      token,
        fields:     fields,
        xfile:      imagen,
        xfileField: imagen != null ? 'imagen' : null,
      );
    }

    return ApiService.patch('/users/$id/', token: token, data: data);
  }

  static Future<void> deactivateUser(int id) async {
    final token = await TokenStorage.getAccessToken();
    await ApiService.patch(
      '/users/$id/deactivate/',
      token: token,
      data:  {'confirmacion': true},
    );
  }

  static Future<void> activateUser(int id) async {
    final token = await TokenStorage.getAccessToken();
    await ApiService.patch(
      '/users/$id/activate/',
      token: token,
      data:  {'confirmacion': true},
    );
  }

  static Future<dynamic> getUsersDocentes() async {
    final token = await TokenStorage.getAccessToken();
    return ApiService.get(
      '/users/?rol=DOCENTE&is_active=true',
      token: token,
    );
  }
}