import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
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
        // Demonstrasi Modul IV: Navigator.pop kembali ke halaman Login
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: WijiBumiColors.lightMint,
      appBar: AppBar(
        title: const Text('Registrasi Akun'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          // Demonstrasi Modul IV: Navigator.pop
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(22),
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
                        'Nama Lengkap',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: WijiBumiColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      CustomTextField(
                        controller: _nameController,
                        hintText: 'Misal: Sari Lestari',
                        prefixIcon: Icons.badge_outlined,
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
                          color: WijiBumiColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      CustomTextField(
                        controller: _emailController,
                        hintText: 'nama@domain.com',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
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
                          color: WijiBumiColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      CustomTextField(
                        controller: _usernameController,
                        hintText: 'username_anda',
                        prefixIcon: Icons.alternate_email_rounded,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Username tidak boleh kosong';
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
                          color: WijiBumiColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      CustomTextField(
                        controller: _phoneController,
                        hintText: '08xxxxxxxxxx',
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 14),

                      const Text(
                        'Password',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: WijiBumiColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      CustomTextField(
                        controller: _passwordController,
                        hintText: 'Minimal 6 karakter',
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
                      const SizedBox(height: 14),

                      const Text(
                        'Konfirmasi Password',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: WijiBumiColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      CustomTextField(
                        controller: _confirmPasswordController,
                        hintText: 'Ulangi password',
                        prefixIcon: Icons.lock_clock_outlined,
                        isPassword: true,
                        validator: (val) {
                          if (val != _passwordController.text) {
                            return 'Konfirmasi password tidak cocok';
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
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
