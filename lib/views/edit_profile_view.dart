import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app.dart';
import '../controllers/auth_controller.dart';
import '../controllers/location_controller.dart';
import '../widgets/glass_feedback.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  @override
  void initState() {
    super.initState();
    final authController = Get.find<AuthController>();
    final user = authController.currentUser.value;
    _nameController.text = user?.name ?? '';
    _phoneController.text = user?.phone ?? '';

    if (Get.isRegistered<LocationController>()) {
      Get.find<LocationController>().loadAddresses();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String _getInitials(String name) {
    final clean = name.trim();
    if (clean.isEmpty) return 'U';
    final parts = clean.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : 'U';
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty) {
      GlassFeedback.showSnackbar(
        title: 'Form Belum Lengkap',
        message: 'Nama lengkap tidak boleh kosong',
        isError: true,
      );
      return;
    }

    if (phone.isEmpty) {
      GlassFeedback.showSnackbar(
        title: 'Form Belum Lengkap',
        message: 'Nomor telepon tidak boleh kosong',
        isError: true,
      );
      return;
    }

    // Validasi Ubah Password (Opsional)
    if (newPassword.isNotEmpty || confirmPassword.isNotEmpty) {
      if (newPassword.length < 6) {
        GlassFeedback.showSnackbar(
          title: 'Kata Sandi Kurang Kuat',
          message: 'Kata sandi baru minimal 6 karakter',
          isError: true,
        );
        return;
      }
      if (newPassword != confirmPassword) {
        GlassFeedback.showSnackbar(
          title: 'Konfirmasi Sandi Berbeda',
          message: 'Kata sandi baru dan konfirmasi tidak cocok',
          isError: true,
        );
        return;
      }
    }

    final authController = Get.find<AuthController>();
    final success = await authController.updateProfile(
      name: name,
      phone: phone,
      newPassword: newPassword.isNotEmpty ? newPassword : null,
    );

    if (success && mounted) {
      Get.back();
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Edit Profil',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Colors.white,
            fontSize: 16.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Column(
          children: [
            // =================================================================
            // 1. Header Avatar & Ringkasan Akun
            // =================================================================
            Obx(() {
              final user = authController.currentUser.value;
              final displayName = _nameController.text.isNotEmpty
                  ? _nameController.text
                  : (user?.name ?? 'Pengguna Wiji Bumi');
              final displayEmail = user?.email ?? 'user@example.com';

              return Column(
                children: [
                  Container(
                    width: 86,
                    height: 86,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.14),
                      border: Border.all(
                        color: const Color(0xFFA7F3D0).withOpacity(0.40),
                        width: 2.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _getInitials(displayName),
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFA7F3D0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    displayEmail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFFC8DDD0),
                    ),
                  ),
                ],
              );
            }),

            const SizedBox(height: 22),

            // =================================================================
            // 2. Kartu 1 — "Informasi Pribadi"
            // =================================================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: DynamicGlassDecoration.glassCard(radius: 18),
              child: Obx(() {
                final user = authController.currentUser.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.person_outline_rounded, size: 20, color: Color(0xFFA7F3D0)),
                        SizedBox(width: 8),
                        Text(
                          'Informasi Pribadi',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Email Terdaftar (Read-Only)
                    const Text(
                      'Email Terdaftar',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.18),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.email_outlined, size: 20, color: Color(0xFFA7F3D0)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              user?.email ?? 'user@example.com',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFFC8DDD0),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFA7F3D0).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFFA7F3D0).withOpacity(0.35),
                                width: 0.8,
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.lock_rounded, size: 10, color: Color(0xFFA7F3D0)),
                                SizedBox(width: 3),
                                Text(
                                  'Terdaftar',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFA7F3D0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Username Terdaftar (Read-Only jika ada)
                    if (user != null && user.username.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Text(
                        'Username Akun',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.18),
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.alternate_email_rounded, size: 20, color: Color(0xFFA7F3D0)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                user.username,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFFC8DDD0),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFA7F3D0).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: const Color(0xFFA7F3D0).withOpacity(0.35),
                                  width: 0.8,
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.lock_rounded, size: 10, color: Color(0xFFA7F3D0)),
                                  SizedBox(width: 3),
                                  Text(
                                    'Terdaftar',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFA7F3D0),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 14),

                    // Nama Lengkap (Editable)
                    const Text(
                      'Nama Lengkap',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _nameController,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13.5,
                        color: Colors.white,
                      ),
                      decoration: DynamicGlassDecoration.inputDecoration(
                        hintText: 'Nama lengkap Anda',
                        prefixIcon: const Icon(Icons.badge_outlined, size: 20, color: Color(0xFFA7F3D0)),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),

                    const SizedBox(height: 14),

                    // Nomor Telepon (Editable)
                    const Text(
                      'Nomor Telepon',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13.5,
                        color: Colors.white,
                      ),
                      decoration: DynamicGlassDecoration.inputDecoration(
                        hintText: '08xxxxxxxxxx',
                        prefixIcon: const Icon(Icons.phone_outlined, size: 20, color: Color(0xFFA7F3D0)),
                      ),
                    ),
                  ],
                );
              }),
            ),

            const SizedBox(height: 18),

            // =================================================================
            // 3. Kartu 2 — "Alamat Pengiriman Utama"
            // =================================================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: DynamicGlassDecoration.glassCard(radius: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 20, color: Color(0xFFA7F3D0)),
                          SizedBox(width: 8),
                          Text(
                            'Alamat Pengiriman',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () async {
                          await Get.toNamed(AppRoutes.ADDRESS);
                          if (Get.isRegistered<LocationController>()) {
                            Get.find<LocationController>().loadAddresses();
                          }
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Kelola Alamat',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFA7F3D0),
                                ),
                              ),
                              SizedBox(width: 2),
                              Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFFA7F3D0)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Pratinjau Alamat Utama
                  Builder(builder: (context) {
                    final locationController = Get.isRegistered<LocationController>()
                        ? Get.find<LocationController>()
                        : null;

                    if (locationController == null) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.18),
                            width: 1.0,
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'Belum ada alamat utama yang dipilih',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              color: Color(0xFFC8DDD0),
                            ),
                          ),
                        ),
                      );
                    }

                    return Obx(() {
                      final address = locationController.selectedAddress.value ??
                          (locationController.addresses.isNotEmpty
                              ? locationController.addresses.first
                              : null);

                      if (address == null) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.18),
                              width: 1.0,
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'Belum ada alamat utama yang dipilih',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                color: Color(0xFFC8DDD0),
                              ),
                            ),
                          ),
                        );
                      }

                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.20),
                            width: 1.0,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFA7F3D0).withOpacity(0.15),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFFA7F3D0).withOpacity(0.35),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.location_on_rounded,
                                      size: 17,
                                      color: Color(0xFFA7F3D0),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    '${address.recipientName} (${address.phone})',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFA7F3D0).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: const Color(0xFFA7F3D0).withOpacity(0.40),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: const Text(
                                    'Utama',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFA7F3D0),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              address.fullAddress,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12.5,
                                color: Color(0xFFC8DDD0),
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      );
                    });
                  }),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // =================================================================
            // 4. Kartu 3 — "Keamanan Akun / Ubah Password (Opsional)"
            // =================================================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: DynamicGlassDecoration.glassCard(radius: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.shield_outlined, size: 20, color: Color(0xFFA7F3D0)),
                      SizedBox(width: 8),
                      Text(
                        'Keamanan Akun',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Kosongkan jika tidak ingin mengubah kata sandi',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFFC8DDD0),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Password Baru
                  const Text(
                    'Kata Sandi Baru',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _newPasswordController,
                    obscureText: !_showNewPassword,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13.5,
                      color: Colors.white,
                    ),
                    decoration: DynamicGlassDecoration.inputDecoration(
                      hintText: 'Minimal 6 karakter',
                      prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20, color: Color(0xFFA7F3D0)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showNewPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          size: 20,
                          color: const Color(0xFFC8DDD0),
                        ),
                        onPressed: () {
                          setState(() {
                            _showNewPassword = !_showNewPassword;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Konfirmasi Password Baru
                  const Text(
                    'Konfirmasi Kata Sandi Baru',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: !_showConfirmPassword,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13.5,
                      color: Colors.white,
                    ),
                    decoration: DynamicGlassDecoration.inputDecoration(
                      hintText: 'Ulangi kata sandi baru',
                      prefixIcon: const Icon(Icons.lock_reset_rounded, size: 20, color: Color(0xFFA7F3D0)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          size: 20,
                          color: const Color(0xFFC8DDD0),
                        ),
                        onPressed: () {
                          setState(() {
                            _showConfirmPassword = !_showConfirmPassword;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // =================================================================
            // 5. Tombol Utama Simpan Perubahan
            // =================================================================
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA7F3D0),
                  foregroundColor: const Color(0xFF142117),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Obx(() {
                  if (authController.isLoading.value) {
                    return const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Color(0xFF142117),
                      ),
                    );
                  }
                  return const Text(
                    'Simpan Perubahan',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF142117),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
