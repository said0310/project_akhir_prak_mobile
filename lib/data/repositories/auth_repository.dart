import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../models/user_model.dart';
import '../providers/api_service.dart';
import '../../storage/pref_service.dart';

class AuthRepository {
  final ApiService apiService;
  final PrefService prefService;

  AuthRepository({required this.apiService, required this.prefService});

  /// Hash password menggunakan SHA-256 (FR-AUTH-06)
  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Registrasi user baru
  Future<UserModel> register({
    required String name,
    required String email,
    required String username,
    required String password,
    String? phone,
  }) async {
    final passwordHash = hashPassword(password);
    return await apiService.registerUser({
      'name': name,
      'email': email,
      'username': username,
      'passwordHash': passwordHash,
      'phone': phone ?? '',
    });
  }

  /// Login user
  Future<UserModel> login({
    required String identifier,
    required String password,
  }) async {
    final passwordHash = hashPassword(password);
    final user = await apiService.loginUser(identifier, passwordHash);

    // Simpan sesi ke SharedPreferences (FR-AUTH-03)
    await prefService.saveSession(
      userId: user.id,
      token: 'session_token_${DateTime.now().millisecondsSinceEpoch}',
    );

    return user;
  }

  /// Update profil pengguna
  Future<UserModel> updateProfile({
    required String userId,
    String? name,
    String? phone,
    String? photoUrl,
  }) async {
    return await apiService.updateUser(userId, {
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (photoUrl != null) 'photoUrl': photoUrl,
    });
  }

  /// Logout (FR-AUTH-04)
  Future<void> logout() async {
    await prefService.clearSession();
  }

  /// Cek sesi aktif saat startup
  bool get isLoggedIn => prefService.isLoggedIn;
  String get currentUserId => prefService.userId;
}
