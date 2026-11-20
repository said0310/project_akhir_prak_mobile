import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WijiBumiColors.backgroundCanvas,
      appBar: AppBar(
        title: const Text('Tentang Aplikasi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          // Demonstrasi Modul IV: Navigator.pop
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Logo Banner
            Container(
              padding: const EdgeInsets.all(24),
              decoration: DynamicGlassDecoration.cleanCard(radius: 16),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: WijiBumiColors.lightMint,
                      shape: BoxShape.circle,
                      border: Border.all(color: WijiBumiColors.softSage, width: 2),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.eco_rounded,
                        size: 40,
                        color: WijiBumiColors.deepForest,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Wiji Bumi',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: WijiBumiColors.deepForest,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Versi 1.0.0 (Tugas Akhir Praktikum Mobile)',
                    style: TextStyle(
                      fontSize: 12,
                      color: WijiBumiColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Platform digital terintegrasi untuk jual beli sayuran organik, buah segar, bunga, dan tanaman hias nusantara.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: WijiBumiColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Rincian Integrasi Modul Praktikum
            Container(
              padding: const EdgeInsets.all(18),
              decoration: DynamicGlassDecoration.cleanCard(radius: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Integrasi Modul Praktikum II - VIII',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: WijiBumiColors.deepForest,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildModuleItem(
                    'Modul II',
                    'Widget, Layout, Container, Row, Column, GridView, Custom Glass Components',
                  ),
                  _buildModuleItem(
                    'Modul III',
                    'StatelessWidget, StatefulWidget, setState() untuk kuantitas & form',
                  ),
                  _buildModuleItem(
                    'Modul IV',
                    'Navigasi Navigator.push/pop, pushReplacement, pushAndRemoveUntil',
                  ),
                  _buildModuleItem(
                    'Modul V',
                    'REST HTTP Client, API Service, Mock Server, Error Handling & Retry',
                  ),
                  _buildModuleItem(
                    'Modul VI',
                    'Shared Preferences (sesi login) & Hive Storage (keranjang, wishlist, pengingat)',
                  ),
                  _buildModuleItem(
                    'Modul VII-A',
                    'Flutter Local Notifications (Immediate pesanan & Scheduled pengingat belanja)',
                  ),
                  _buildModuleItem(
                    'Modul VII-B',
                    'LBS & Geolocator (izin GPS, deteksi posisi, hitung jarak & ongkir otomatis)',
                  ),
                  _buildModuleItem(
                    'Modul VIII',
                    'GetX State Management, Reactive Obx, Dependency Injection & Named Routes',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleItem(String module, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: DynamicGlassDecoration.accentPill(
              radius: 6,
              fillColor: WijiBumiColors.lightMint,
            ),
            child: Text(
              module,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: WijiBumiColors.deepForest,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(
                fontSize: 12,
                color: WijiBumiColors.textSecondary,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
