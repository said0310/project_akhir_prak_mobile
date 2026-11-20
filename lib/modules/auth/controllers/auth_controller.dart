import 'package:get/get.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../widgets/glass_feedback.dart';

class AuthController extends GetxController {
  final AuthRepository authRepository;

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
    }
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
    currentUser.value = null;
    isLoggedIn.value = false;
    // Sesuai BR-10: Logout tidak menghapus keranjang dan wishlist
  }
}
