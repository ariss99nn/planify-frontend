import '../../../core/api/api_service.dart';
import 'package:image_picker/image_picker.dart';

class AuthService {

  // =========================
  // LOGIN
  // =========================
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    return await ApiService.post(
      '/auth/login/',
      data: {
        'email': email.trim().toLowerCase(),
        'password': password,
      },
    );
  }

  // =========================
  // REGISTER
  // =========================
  static Future<Map<String, dynamic>> register({
    required String nombre,
    required String apellido,
    required String email,
    required String password,
    required String password2,
    XFile? imagen,
  }) async {
    return await ApiService.postMultipart(
      '/auth/register/',
      fields: {
        'nombre':    nombre.trim(),
        'apellido':  apellido.trim(),
        'email':     email.trim().toLowerCase(),
        'password':  password,
        'password2': password2,
      },
      xfile: imagen,
      xfileField: 'imagen',
    );
  }

  // =========================
  // PROFILE
  // =========================
  static Future<Map<String, dynamic>> getProfile(String token) async {
    return await ApiService.get(
      '/auth/profile/',
      token: token,
    );
  }

  static Future<Map<String, dynamic>> updateProfile({
    required String token,
    required Map<String, dynamic> data,
  }) async {
    return await ApiService.patch(
      '/auth/profile/',
      token: token,
      data: data,
    );
  }

  static Future<Map<String, dynamic>> updateProfileWithImage({
    required String token,
    String? nombre,
    String? apellido,
    XFile?  imagen,
    bool    eliminarImagen = false,
  }) async {
    final fields = <String, String>{};
    if (nombre != null)   fields['nombre']   = nombre.trim();
    if (apellido != null) fields['apellido'] = apellido.trim();

    // Si el usuario quitó la foto, envía el campo vacío para que el backend
    // sepa que debe borrarla. Solo aplica cuando no se subió imagen nueva.
    if (eliminarImagen && imagen == null) {
      fields['imagen'] = '';
    }

    return await ApiService.patchMultipart(
      '/auth/profile/',
      token:      token,
      fields:     fields,
      xfile:      imagen,
      xfileField: imagen != null ? 'imagen' : null,
    );
  }

  // =========================
  // VERIFY EMAIL
  // =========================
  static Future<Map<String, dynamic>> verifyEmail({
    required String email,
    required String code,
  }) async {
    return await ApiService.post(
      '/auth/verify-email/',
      data: {
        'email': email.trim().toLowerCase(),
        'code':  code.trim(),
      },
    );
  }

  // =========================
  // RESEND VERIFICATION
  // =========================
  static Future<void> resendVerification(String email) async {
    await ApiService.post(
      '/auth/resend-verification/',
      data: {'email': email.trim().toLowerCase()},
    );
  }

  // =========================
  // PASSWORD RESET REQUEST
  // =========================
  static Future<void> requestPasswordReset(String email) async {
    await ApiService.post(
      '/auth/password-reset/',
      data: {'email': email.trim().toLowerCase()},
    );
  }

  // =========================
  // PASSWORD RESET CONFIRM
  // =========================
  static Future<void> confirmPasswordReset({
    required String code,
    required String password,
  }) async {
    await ApiService.post(
      '/auth/password-reset/confirm/',
      data: {
        'code':     code.trim(),
        'password': password,
      },
    );
  }

  // =========================
  // EMAIL CHANGE REQUEST
  // =========================
  static Future<void> requestEmailChange({
    required String token,
    required String newEmail,
  }) async {
    await ApiService.post(
      '/auth/profile/email/',
      token: token,
      data: {'new_email': newEmail.trim().toLowerCase()},
    );
  }

  // =========================
  // EMAIL CHANGE CONFIRM
  // =========================
  static Future<void> confirmEmailChange({
    required String token,
    required String code,
  }) async {
    await ApiService.post(
      '/auth/profile/email/confirm/',
      token: token,
      data: {'code': code.trim()},
    );
  }

  // =========================
  // LOGOUT
  // =========================
  static Future<void> logout({
    required String refreshToken,
    required String accessToken,
  }) async {
    await ApiService.post(
      '/auth/logout/',
      token: accessToken,
      data: {'refresh': refreshToken},
    );
  }

  // =========================
// CHECK EMAIL EXISTS (para validación en register y edit profile)
// =========================
  static Future<void> checkEmailExists(String email) async {
    await ApiService.post(
      '/auth/check-email/',
      data: {'email': email.trim().toLowerCase()},
    );
  // Si el email no existe, el backend lanza 400 → ApiService lanza ApiException
  }
}
