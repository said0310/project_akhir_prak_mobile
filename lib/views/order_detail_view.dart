import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../app.dart';
import '../models/models.dart';
import '../controllers/shop_controller.dart';
import '../widgets/custom_button.dart';
import '../widgets/glass_feedback.dart';

class OrderDetailView extends StatelessWidget {
  const OrderDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final orderController = Get.find<ShopController>();

    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final dateFormatter = DateFormat('dd MMMM yyyy, HH:mm', 'id_ID');

    final OrderModel? initialOrder =
        Get.arguments is OrderModel ? Get.arguments as OrderModel : null;

    if (initialOrder == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Pesanan')),
        body: const Center(child: Text('Data pesanan tidak ditemukan.')),
      );
    }

    return Scaffold(
      backgroundColor: WijiBumiColors.backgroundCanvas,
      appBar: AppBar(
        title: const Text('Detail Pesanan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          tooltip: 'Kembali',
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Get.back();
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_rounded),
            tooltip: 'Ke Beranda',
            onPressed: () {
              Get.offAllNamed(AppRoutes.MAIN);
            },
          ),
        ],
      ),
      body: Obx(() {
        final order = orderController.orders.firstWhere(
          (o) => o.id == initialOrder.id,
          orElse: () => initialOrder,
        );

        final canCancel = order.status == 'Menunggu Pembayaran' || order.status == 'Diproses';
        final canAdvance = order.status != 'Selesai' && order.status != 'Dibatalkan';

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kartu Status Pesanan
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: DynamicGlassDecoration.cleanCard(radius: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Status Transaksi',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: WijiBumiColors.textMuted,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: DynamicGlassDecoration.accentPill(
                            radius: 8,
                            fillColor: WijiBumiColors.lightMint,
                            borderColor: WijiBumiColors.freshLeaf,
                          ),
                          child: Text(
                            order.status,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: WijiBumiColors.deepForest,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      order.orderNumber,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: WijiBumiColors.deepForest,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Waktu: ${dateFormatter.format(order.createdAt)}',
                      style: const TextStyle(fontSize: 12, color: WijiBumiColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Kartu Alamat Pengiriman
              const Text(
                'Alamat Pengiriman (Snapshot)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: WijiBumiColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: DynamicGlassDecoration.cleanCard(radius: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${order.address.recipientName} (${order.address.phone})',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: WijiBumiColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.address.fullAddress,
                      style: const TextStyle(fontSize: 12, color: WijiBumiColors.textSecondary),
                    ),
                    Text(
                      '${order.address.district}, ${order.address.city}',
                      style: const TextStyle(fontSize: 12, color: WijiBumiColors.textMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Kartu Daftar Item Terbeli
              const Text(
                'Daftar Produk',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: WijiBumiColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: DynamicGlassDecoration.cleanCard(radius: 14),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: order.items.length,
                  separatorBuilder: (_, __) => const Divider(height: 16),
                  itemBuilder: (context, index) {
                    final item = order.items[index];
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: WijiBumiColors.textPrimary),
                              ),
                              Text(
                                '${item.quantity} ${item.unit} x ${currencyFormatter.format(item.price)}',
                                style: const TextStyle(fontSize: 11, color: WijiBumiColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          currencyFormatter.format(item.subtotal),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: WijiBumiColors.deepForest),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Rincian Pembayaran
              const Text(
                'Rincian Biaya & Metode Pembayaran',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: WijiBumiColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: DynamicGlassDecoration.cleanCard(radius: 14),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Metode Pembayaran', style: TextStyle(fontSize: 12, color: WijiBumiColors.textSecondary)),
                        Text(order.paymentMethod, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal Produk', style: TextStyle(fontSize: 12, color: WijiBumiColors.textSecondary)),
                        Text(currencyFormatter.format(order.subtotal), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Ongkos Kirim', style: TextStyle(fontSize: 12, color: WijiBumiColors.textSecondary)),
                        Text(
                          order.shippingCost == 0 ? 'Gratis' : currencyFormatter.format(order.shippingCost),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: order.shippingCost == 0 ? WijiBumiColors.success : WijiBumiColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Transaksi',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: WijiBumiColors.deepForest),
                        ),
                        Text(
                          currencyFormatter.format(order.total),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: WijiBumiColors.deepForest),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Tombol Aksi Simulasi Status & Batalkan
              if (canAdvance) ...[
                CustomButton(
                  text: '⚡ Lanjutkan Status Pesanan (Simulasi Demo)',
                  icon: Icons.fast_forward_rounded,
                  variant: ButtonVariant.secondaryGlass,
                  onPressed: () {
                    orderController.advanceStatus(order.id);
                  },
                ),
                const SizedBox(height: 12),
              ],

              if (canCancel)
                CustomButton(
                  text: 'Batalkan Pesanan',
                  icon: Icons.cancel_outlined,
                  onPressed: () async {
                    final confirm = await GlassFeedback.showConfirmDialog(
                      context: context,
                      title: 'Batalkan Pesanan?',
                      message: 'Apakah Anda yakin ingin membatalkan pesanan ${order.orderNumber}?',
                      confirmText: 'Ya, Batalkan',
                      isDestructive: true,
                    );
                    if (confirm == true) {
                      orderController.cancelOrder(order.id);
                    }
                  },
                ),
            ],
          ),
        );
      }),
    );
  }
}
