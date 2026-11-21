import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app.dart';
import '../services/api_service.dart';
import '../controllers/auth_controller.dart';
import '../widgets/glass_feedback.dart';
import 'about_view.dart';
import 'login_view.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool _offlineMode = ApiService.simulateNetworkError;

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: WijiBumiColors.backgroundCanvas,
      appBar: AppBar(
        title: const Text('Profil Saya'),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        child: Column(
          children: [
            // 1. Header Profil Kaca dengan Avatar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: DynamicGlassDecoration.cleanCard(radius: 16),
              child: Obx(() {
                final user = authController.currentUser.value;
                final name = user?.name ?? 'Sari Lestari';
                final email = user?.email ?? 'sari@example.com';
                final phone = user?.phone.isNotEmpty == true ? user!.phone : '0812-3456-7890';

                return Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: WijiBumiColors.softSage,
                          width: 3.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: WijiBumiColors.deepForest.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: user?.photoUrl.isNotEmpty == true
                            ? Image.network(
                                user!.photoUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _buildAvatarFallback(),
                              )
                            : _buildAvatarFallback(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: WijiBumiColors.deepForest,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: const TextStyle(
                        fontSize: 12,
                        color: WijiBumiColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      phone,
                      style: const TextStyle(
                        fontSize: 12,
                        color: WijiBumiColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.edit_outlined, size: 14),
                      label: const Text('Edit Profil'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: WijiBumiColors.deepForest,
                        side: const BorderSide(color: WijiBumiColors.softSage),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      ),
                      onPressed: () {
                        Get.toNamed(AppRoutes.EDIT_PROFILE);
                      },
                    ),
                  ],
                );
              }),
            ),
            const SizedBox(height: 20),

            // 2. Daftar Menu
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: DynamicGlassDecoration.cleanCard(radius: 16),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.location_on_outlined,
                    title: 'Alamat Pengiriman (LBS)',
                    subtitle: 'Kelola alamat & koordinat GPS',
                    onTap: () => Get.toNamed(AppRoutes.ADDRESS),
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildMenuItem(
                    icon: Icons.receipt_long_outlined,
                    title: 'Riwayat Pesanan',
                    subtitle: 'Lacak status & transaksi belanja',
                    onTap: () => Get.toNamed(AppRoutes.ORDERS),
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildMenuItem(
                    icon: Icons.alarm_outlined,
                    title: 'Pengingat Belanja',
                    subtitle: 'Jadwal notifikasi belanja rutin',
                    onTap: () => Get.toNamed(AppRoutes.REMINDERS),
                  ),
                  const Divider(height: 1, indent: 56),

                  // Toggle Simulasi Jaringan
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _offlineMode ? WijiBumiColors.error.withOpacity(0.12) : WijiBumiColors.lightMint,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _offlineMode ? Icons.wifi_off_rounded : Icons.wifi_rounded,
                        color: _offlineMode ? WijiBumiColors.error : WijiBumiColors.deepForest,
                        size: 20,
                      ),
                    ),
                    title: const Text(
                      'Simulasi Mode Offline (TC-08 / TC-15)',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: WijiBumiColors.textPrimary),
                    ),
                    subtitle: Text(
                      _offlineMode ? 'Mode simulasi mati jaringan aktif' : 'Jaringan online normal',
                      style: const TextStyle(fontSize: 11, color: WijiBumiColors.textMuted),
                    ),
                    trailing: Switch(
                      value: _offlineMode,
                      activeColor: WijiBumiColors.error,
                      onChanged: (val) {
                        setState(() {
                          _offlineMode = val;
                          ApiService.simulateNetworkError = val;
                        });
                        GlassFeedback.showSnackbar(
                          title: val ? 'Mode Offline Aktif' : 'Mode Online Aktif',
                          message: val
                              ? 'Request API sekarang akan gagal untuk pengujian Error State & Retry.'
                              : 'Koneksi jaringan simulasi kembali normal.',
                        );
                      },
                    ),
                  ),
                  const Divider(height: 1, indent: 56),

                  // Navigasi ke Tentang Aplikasi
                  _buildMenuItem(
                    icon: Icons.info_outline_rounded,
                    title: 'Tentang Aplikasi',
                    subtitle: 'Wiji Bumi v1.0 • Praktikum Mobile',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AboutView()),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 3. Tombol Logout
            Container(
              decoration: DynamicGlassDecoration.cleanCard(radius: 14),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: WijiBumiColors.error.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: WijiBumiColors.error,
                    size: 20,
                  ),
                ),
                title: const Text(
                  'Keluar dari Akun (Logout)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: WijiBumiColors.error,
                  ),
                ),
                onTap: () async {
                  final confirm = await GlassFeedback.showConfirmDialog(
                    context: context,
                    title: 'Konfirmasi Keluar',
                    message: 'Apakah Anda yakin ingin keluar dari akun? Data keranjang dan wishlist Anda tetap tersimpan.',
                    confirmText: 'Keluar',
                    isDestructive: true,
                  );

                  if (confirm == true && context.mounted) {
                    await authController.logout();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginView()),
                      (route) => false,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarFallback() {
    return Container(
      color: WijiBumiColors.lightMint,
      child: const Center(
        child: Icon(
          Icons.person_rounded,
          size: 44,
          color: WijiBumiColors.deepForest,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: WijiBumiColors.lightMint,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: WijiBumiColors.deepForest, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: WijiBumiColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 11, color: WijiBumiColors.textMuted),
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: WijiBumiColors.textMuted),
      onTap: onTap,
    );
  }
}
