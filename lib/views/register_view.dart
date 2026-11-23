import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../controllers/auth_controller.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onRegister() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authController = Get.find<AuthController>();
      final success = await authController.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        phone: _phoneController.text.trim(),
      );

      if (success && mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Registrasi Akun',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 30, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    // Header Logo
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.14),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.30),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4CAF50).withOpacity(0.20),
                            blurRadius: 18,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.eco_rounded,
                          size: 38,
                          color: Color(0xFFA7F3D0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Wiji Bumi',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Daftar Akun Baru',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFC8DDD0),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Panel Formulir Liquid Glass
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                        child: Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.28),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.20),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Nama Lengkap',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFC8DDD0),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                CustomTextField(
                                  controller: _nameController,
                                  hintText: 'Misal: Sari Lestari',
                                  prefixIcon: Icons.badge_outlined,
                                  textColor: Colors.white,
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty) {
                                      return 'Nama tidak boleh kosong';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 14),

                                const Text(
                                  'Email',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFC8DDD0),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                CustomTextField(
                                  controller: _emailController,
                                  hintText: 'nama@domain.com',
                                  prefixIcon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  textColor: Colors.white,
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty) {
                                      return 'Email tidak boleh kosong';
                                    }
                                    if (!val.contains('@') || !val.contains('.')) {
                                      return 'Format email tidak valid';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 14),

                                const Text(
                                  'Username',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFC8DDD0),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                CustomTextField(
                                  controller: _usernameController,
                                  hintText: 'Pilih username unik',
                                  prefixIcon: Icons.person_outline_rounded,
                                  textColor: Colors.white,
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty) {
                                      return 'Username tidak boleh kosong';
                                    }
                                    if (val.trim().length < 3) {
                                      return 'Username minimal 3 karakter';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 14),

                                const Text(
                                  'Nomor Telepon',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFC8DDD0),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                CustomTextField(
                                  controller: _phoneController,
                                  hintText: '081234567890',
                                  prefixIcon: Icons.phone_outlined,
                                  keyboardType: TextInputType.phone,
                                  textColor: Colors.white,
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty) {
                                      return 'Nomor telepon tidak boleh kosong';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 14),

                                const Text(
                                  'Password',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFC8DDD0),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                CustomTextField(
                                  controller: _passwordController,
                                  hintText: 'Minimal 6 karakter',
                                  prefixIcon: Icons.lock_outline_rounded,
                                  isPassword: true,
                                  textColor: Colors.white,
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
                                const SizedBox(height: 14),

                                const Text(
                                  'Konfirmasi Password',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFC8DDD0),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                CustomTextField(
                                  controller: _confirmPasswordController,
                                  hintText: 'Ulangi password di atas',
                                  prefixIcon: Icons.lock_reset_rounded,
                                  isPassword: true,
                                  textColor: Colors.white,
                                  validator: (val) {
                                    if (val == null || val.isEmpty) {
                                      return 'Konfirmasi password tidak boleh kosong';
                                    }
                                    if (val != _passwordController.text) {
                                      return 'Password konfirmasi tidak cocok';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 24),

                                Obx(
                                  () => CustomButton(
                                    text: 'Daftar Sekarang',
                                    isLoading: authController.isLoading.value,
                                    onPressed: _onRegister,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Link Sudah Punya Akun
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Sudah punya akun? ',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: const Text(
                            'Masuk',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFA7F3D0),
                              decoration: TextDecoration.underline,
                              decorationColor: Color(0xFFA7F3D0),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
