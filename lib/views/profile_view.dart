import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app.dart';
import '../services/api_service.dart';
import '../controllers/auth_controller.dart';
import '../widgets/custom_button.dart';
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
        backgroundColor: WijiBumiColors.deepForest,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Profil Saya',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          children: [
            // 1. Header Profil dengan Avatar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: DynamicGlassDecoration.glassCard(radius: 16),
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
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: user != null && user.photoUrl.isNotEmpty
                            ? (user.photoUrl.startsWith('http://') || user.photoUrl.startsWith('https://')
                                ? Image.network(
                                    user.photoUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => _buildAvatarFallback(),
                                  )
                                : Image.asset(
                                    user.photoUrl.startsWith('assets/')
                                        ? user.photoUrl
                                        : 'assets/images/products/${user.photoUrl}',
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => _buildAvatarFallback(),
                                  ))
                            : _buildAvatarFallback(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: WijiBumiColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: WijiBumiColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      phone,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                        backgroundColor: Colors.white.withOpacity(0.12),
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white.withOpacity(0.28)),
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
            const SizedBox(height: 18),

            // 2. Daftar Menu
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: DynamicGlassDecoration.glassCard(radius: 16),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.location_on_outlined,
                    title: 'Alamat Pengiriman (LBS)',
                    subtitle: 'Kelola alamat & koordinat GPS',
                    onTap: () => Get.toNamed(AppRoutes.ADDRESS),
                  ),
                  const Divider(color: Color(0xFFEAF0EB), height: 1, indent: 64),
                  _buildMenuItem(
                    icon: Icons.receipt_long_outlined,
                    title: 'Pesanan Saya',
                    subtitle: 'Lacak status & transaksi belanja',
                    onTap: () => Get.toNamed(AppRoutes.ORDERS),
                  ),
                  const Divider(color: Color(0xFFEAF0EB), height: 1, indent: 64),
                  _buildMenuItem(
                    icon: Icons.alarm_outlined,
                    title: 'Pengingat Belanja Rutin',
                    subtitle: 'Jadwalkan notifikasi lokal otomatis',
                    onTap: () => Get.toNamed(AppRoutes.REMINDERS),
                  ),
                  Divider(color: Colors.white.withOpacity(0.14), height: 1, indent: 64),
                  _buildMenuItem(
                    icon: Icons.favorite_border_rounded,
                    title: 'Wishlist Favorit',
                    subtitle: 'Daftar produk sayuran & tanaman impian',
                    onTap: () => Get.toNamed(AppRoutes.WISHLIST),
                  ),
                  Divider(color: Colors.white.withOpacity(0.14), height: 1, indent: 64),
                  _buildMenuItem(
                    icon: Icons.info_outline_rounded,
                    title: 'Tentang Aplikasi',
                    subtitle: 'Wiji Bumi v1.0.0 & Informasi Pengembang',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AboutView()),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // 3. Pengaturan Simulasi Jaringan (Mode Offline)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: DynamicGlassDecoration.glassCard(radius: 16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.24)),
                    ),
                    child: const Icon(
                      Icons.wifi_off_rounded,
                      color: Color(0xFFA7F3D0),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Simulasi Mode Offline',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: WijiBumiColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Uji coba error handling & data SQLite',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: WijiBumiColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _offlineMode,
                    activeColor: WijiBumiColors.freshLeaf,
                    onChanged: (val) {
                      setState(() {
                        _offlineMode = val;
                        ApiService.simulateNetworkError = val;
                      });
                      GlassFeedback.showSnackbar(
                        title: val ? 'Mode Offline Aktif' : 'Mode Offline Non-Aktif',
                        message: val
                            ? 'Aplikasi mensimulasikan kegagalan koneksi internet.'
                            : 'Koneksi jaringan dikembalikan ke normal.',
                        isError: val,
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 4. Tombol Logout
            CustomButton(
              text: 'Keluar dari Akun',
              icon: Icons.logout_rounded,
              onPressed: () async {
                final confirm = await GlassFeedback.showConfirmDialog(
                  context: context,
                  title: 'Keluar Akun?',
                  message: 'Sesi akun Anda akan diakhiri di perangkat ini.',
                  confirmText: 'Keluar',
                  isDestructive: true,
                );

                if (confirm == true) {
                  await authController.logout();
                  if (mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginView()),
                      (route) => false,
                    );
                  }
                }
              },
            ),
          ],
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
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.24)),
        ),
        child: Icon(icon, color: const Color(0xFFA7F3D0), size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
          color: WijiBumiColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 11.5,
          color: WijiBumiColors.textSecondary,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        size: 22,
        color: WijiBumiColors.textSecondary,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }

  Widget _buildAvatarFallback() {
    return Container(
      color: Colors.white.withOpacity(0.12),
      child: const Center(
        child: Icon(
          Icons.person_rounded,
          size: 46,
          color: Color(0xFFA7F3D0),
        ),
      ),
    );
  }
}
