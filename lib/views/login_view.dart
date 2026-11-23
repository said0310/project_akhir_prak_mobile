import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../controllers/auth_controller.dart';
import 'register_view.dart';
import 'main_view.dart';

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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1C2B1E),
              Color(0xFF2E5E3A),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Ambient glowing emerald orb
            Positioned(
              top: -40,
              right: -30,
              child: IgnorePointer(
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF4CAF50).withOpacity(0.35),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
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
                          color: WijiBumiColors.lightMint,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: WijiBumiColors.softSage,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 12,
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
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Masuk ke Akun Anda',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFFD8E8DC),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Panel Formulir
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: WijiBumiColors.borderSage,
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.14),
                              blurRadius: 18,
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
                                textColor: WijiBumiColors.textPrimary,
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
                                hintText: 'Masukkan password',
                                prefixIcon: Icons.lock_outline_rounded,
                                isPassword: true,
                                textColor: WijiBumiColors.textPrimary,
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return 'Password tidak boleh kosong';
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
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Link Daftar Akun Baru
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Belum punya akun? ',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFFD8E8DC),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const RegisterView()),
                              );
                            },
                            child: const Text(
                              'Daftar di sini',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
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
          ],
        ),
      ),
    );
  }
}
