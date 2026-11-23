import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app.dart';
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
      backgroundColor: WijiBumiColors.backgroundCanvas,
      appBar: AppBar(
        backgroundColor: WijiBumiColors.deepForest,
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: WijiBumiColors.borderSage,
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
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
                        textColor: WijiBumiColors.textPrimary,
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
                        textColor: WijiBumiColors.textPrimary,
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
                        hintText: 'Pilih username unik',
                        prefixIcon: Icons.person_outline_rounded,
                        textColor: WijiBumiColors.textPrimary,
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
                          color: WijiBumiColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      CustomTextField(
                        controller: _phoneController,
                        hintText: '081234567890',
                        prefixIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        textColor: WijiBumiColors.textPrimary,
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
                          color: WijiBumiColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      CustomTextField(
                        controller: _passwordController,
                        hintText: 'Minimal 6 karakter',
                        prefixIcon: Icons.lock_outline_rounded,
                        isPassword: true,
                        textColor: WijiBumiColors.textPrimary,
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
                        hintText: 'Ulangi password di atas',
                        prefixIcon: Icons.lock_reset_rounded,
                        isPassword: true,
                        textColor: WijiBumiColors.textPrimary,
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
                          text: 'Daftar Akun',
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
