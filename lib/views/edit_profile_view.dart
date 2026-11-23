import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../controllers/auth_controller.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final authController = Get.find<AuthController>();
    final user = authController.currentUser.value;
    _nameController.text = user?.name ?? '';
    _phoneController.text = user?.phone ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
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
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 30, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Edit Profil',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: DynamicGlassDecoration.glassCard(radius: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Perbarui Informasi Akun',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: WijiBumiColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Nama Lengkap',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: WijiBumiColors.textPrimary),
              ),
              const SizedBox(height: 6),
              CustomTextField(
                controller: _nameController,
                hintText: 'Nama lengkap Anda',
                prefixIcon: Icons.badge_outlined,
                textColor: WijiBumiColors.textPrimary,
              ),
              const SizedBox(height: 14),
              const Text(
                'Nomor Telepon',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: WijiBumiColors.textPrimary),
              ),
              const SizedBox(height: 6),
              CustomTextField(
                controller: _phoneController,
                hintText: '08xxxxxxxxxx',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                textColor: WijiBumiColors.textPrimary,
              ),
              const SizedBox(height: 24),
              Obx(
                () => CustomButton(
                  text: 'Simpan Perubahan',
                  isLoading: authController.isLoading.value,
                  onPressed: () async {
                    await authController.updateProfile(
                      name: _nameController.text.trim(),
                      phone: _phoneController.text.trim(),
                    );
                    Get.back();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
