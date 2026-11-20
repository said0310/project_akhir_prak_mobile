import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/order_model.dart';
import '../../../widgets/custom_button.dart';
import '../../../app/routes/app_routes.dart';

class OrderSuccessView extends StatelessWidget {
  const OrderSuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final OrderModel? order = Get.arguments is OrderModel ? Get.arguments as OrderModel : null;

    final orderNumber = order?.orderNumber ?? 'WB-20261118-8821';
    final total = order?.total ?? 0.0;
    final paymentMethod = order?.paymentMethod ?? 'Transfer Bank';

    return Scaffold(
      backgroundColor: WijiBumiColors.lightMint,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: WijiBumiColors.freshLeaf,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: WijiBumiColors.deepForest.withOpacity(0.10),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Ikon Centang Hijau Besar
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: WijiBumiColors.lightMint,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: WijiBumiColors.freshLeaf,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 46,
                      color: WijiBumiColors.deepForest,
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Pesanan Berhasil Dibuat!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: WijiBumiColors.deepForest,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Terima kasih! Pesanan Anda telah diterima dan segera disiapkan oleh petani mitra kami.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: WijiBumiColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Kotak Detail Kaca
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: WijiBumiColors.lightMint.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: WijiBumiColors.softSage.withOpacity(0.8),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Nomor Pesanan',
                              style: TextStyle(fontSize: 12, color: WijiBumiColors.textMuted),
                            ),
                            Text(
                              orderNumber,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: WijiBumiColors.deepForest,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Metode Pembayaran',
                              style: TextStyle(fontSize: 12, color: WijiBumiColors.textMuted),
                            ),
                            Text(
                              paymentMethod,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: WijiBumiColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Tagihan',
                              style: TextStyle(fontSize: 12, color: WijiBumiColors.textMuted),
                            ),
                            Text(
                              currencyFormatter.format(total),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: WijiBumiColors.deepForest,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Tombol Aksi
                  CustomButton(
                    text: 'Lihat Riwayat Pesanan',
                    variant: ButtonVariant.secondaryGlass,
                    onPressed: () {
                      Get.offAllNamed(AppRoutes.MAIN);
                      Get.toNamed(AppRoutes.ORDERS);
                    },
                  ),
                  const SizedBox(height: 10),
                  CustomButton(
                    text: 'Kembali ke Beranda',
                    onPressed: () {
                      // Get.offAllNamed ke halaman utama (PRD Bagian 11)
                      Get.offAllNamed(AppRoutes.MAIN);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
