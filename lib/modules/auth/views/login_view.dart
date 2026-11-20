import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../controllers/auth_controller.dart';
import 'register_view.dart';
import '../../main/views/main_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authController = Get.find<AuthController>();
      final success = await authController.login(
        _identifierController.text.trim(),
        _passwordController.text,
      );

      if (success && mounted) {
        // Navigasi masuk ke antarmuka utama
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainView()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: WijiBumiColors.lightMint,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Header Logo
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: WijiBumiColors.softSage,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: WijiBumiColors.deepForest.withOpacity(0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.eco_rounded,
                      size: 38,
                      color: WijiBumiColors.deepForest,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Wiji Bumi',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: WijiBumiColors.deepForest,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Masuk ke Akun Anda',
                  style: TextStyle(
                    fontSize: 13,
                    color: WijiBumiColors.textMuted,
                  ),
                ),
                const SizedBox(height: 28),

                // Panel Kaca Utama (Tier 1/2 Glass Container)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.88),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: WijiBumiColors.softSage,
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: WijiBumiColors.deepForest.withOpacity(0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Email atau Username',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: WijiBumiColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          controller: _identifierController,
                          hintText: 'Masukkan email atau username',
                          prefixIcon: Icons.person_outline_rounded,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Email atau username tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'Password',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: WijiBumiColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          controller: _passwordController,
                          hintText: 'Masukkan password Anda',
                          prefixIcon: Icons.lock_outline_rounded,
                          isPassword: true,
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Password tidak boleh kosong';
                            }
                            if (val.length < 6) {
                              return 'Password minimal 6 karakter';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        Obx(
                          () => CustomButton(
                            text: 'Masuk Sekarang',
                            isLoading: authController.isLoading.value,
                            onPressed: _onLogin,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Quick Demo Fill
                        Center(
                          child: TextButton(
                            onPressed: () {
                              _identifierController.text = 'sari@example.com';
                              _passwordController.text = 'password123';
                            },
                            child: const Text(
                              'Gunakan Akun Demo (Sari)',
                              style: TextStyle(
                                fontSize: 12,
                                color: WijiBumiColors.freshLeaf,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Navigasi ke Registrasi via Navigator.push (Demonstrasi Modul IV)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Belum memiliki akun? ',
                      style: TextStyle(
                        fontSize: 13,
                        color: WijiBumiColors.textSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Demonstrasi Modul IV: Navigator.push
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const RegisterView()),
                        );
                      },
                      child: const Text(
                        'Daftar di sini',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: WijiBumiColors.deepForest,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
