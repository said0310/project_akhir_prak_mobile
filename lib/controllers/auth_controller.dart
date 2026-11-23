import 'dart:async';

import 'package:get/get.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../services/database_helper.dart';
import '../widgets/glass_feedback.dart';

class AuthController extends GetxController {
  static const Duration _sessionTimeout = Duration(minutes: 5);

  final AuthRepository authRepository;
  Timer? _autoLogoutTimer;

  AuthController({required this.authRepository});

  final RxBool isLoading = false.obs;
  final RxBool isLoggedIn = false.obs;
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  @override
  void onInit() {
    super.onInit();
    checkSession();
  }

  void checkSession() {
    isLoggedIn.value = authRepository.isLoggedIn;
    if (isLoggedIn.value) {
      // Mock user yang tersimpan di sesi
      currentUser.value = UserModel(
        id: authRepository.currentUserId.isNotEmpty ? authRepository.currentUserId : 'user_1',
        name: 'Sari Lestari',
        email: 'sari@example.com',
        username: 'sari_lestari',
        passwordHash: '',
        phone: '081234567890',
      );
      _scheduleAutoLogout();
    }
  }

  void _scheduleAutoLogout() {
    _autoLogoutTimer?.cancel();
    _autoLogoutTimer = Timer(_sessionTimeout, _logoutAfterTimeout);
  }

  Future<void> _logoutAfterTimeout() async {
    await logout();
    Get.offAllNamed('/login');
  }

  Future<bool> login(String identifier, String password) async {
    if (identifier.trim().isEmpty || password.trim().isEmpty) {
      GlassFeedback.showSnackbar(
        title: 'Form Belum Lengkap',
        message: 'Silakan isi email/username dan password',
        isError: true,
      );
      return false;
    }

    try {
      isLoading.value = true;
      final user = await authRepository.login(
        identifier: identifier.trim(),
        password: password,
      );
      currentUser.value = user;
      isLoggedIn.value = true;
      _scheduleAutoLogout();
      GlassFeedback.showSnackbar(
        title: 'Berhasil Masuk',
        message: 'Selamat datang kembali, ${user.name}!',
      );
      return true;
    } catch (e) {
      GlassFeedback.showSnackbar(
        title: 'Gagal Masuk',
        message: e.toString().replaceAll('Exception: ', '').replaceAll('HttpException: ', ''),
        isError: true,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String username,
    required String password,
    String? phone,
  }) async {
    try {
      isLoading.value = true;
      final user = await authRepository.register(
        name: name.trim(),
        email: email.trim(),
        username: username.trim(),
        password: password,
        phone: phone?.trim(),
      );
      try {
        await DatabaseHelper.saveUser(
          id: user.id,
          name: user.name,
          email: user.email,
          username: user.username,
          phone: user.phone,
          password: password,
          passwordHash: user.passwordHash,
          photoUrl: user.photoUrl,
          createdAt: user.createdAt,
        );
      } catch (_) {}
      GlassFeedback.showSnackbar(
        title: 'Registrasi Berhasil',
        message: 'Akun berhasil dibuat untuk ${user.name}. Silakan login.',
      );
      return true;
    } catch (e) {
      GlassFeedback.showSnackbar(
        title: 'Gagal Mendaftar',
        message: e.toString().replaceAll('Exception: ', '').replaceAll('HttpException: ', ''),
        isError: true,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile({
    required String name,
    required String phone,
  }) async {
    if (currentUser.value == null) return;
    try {
      isLoading.value = true;
      final updated = await authRepository.updateProfile(
        userId: currentUser.value!.id,
        name: name,
        phone: phone,
      );
      currentUser.value = updated;
      GlassFeedback.showSnackbar(
        title: 'Profil Diperbarui',
        message: 'Data profil berhasil disimpan.',
      );
    } catch (e) {
      GlassFeedback.showSnackbar(
        title: 'Gagal Memperbarui Profil',
        message: e.toString(),
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await authRepository.logout();
    _autoLogoutTimer?.cancel();
    _autoLogoutTimer = null;
    currentUser.value = null;
    isLoggedIn.value = false;
    // Sesuai BR-10: Logout tidak menghapus keranjang dan wishlist
  }

  @override
  void onClose() {
    _autoLogoutTimer?.cancel();
    super.onClose();
  }
}
