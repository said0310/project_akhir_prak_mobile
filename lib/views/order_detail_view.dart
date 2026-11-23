import 'dart:ui';
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
        final canChangePayment = order.status != 'Selesai' && order.status != 'Dibatalkan';

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
                        const Expanded(
                          child: Text(
                            'Status Transaksi',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: WijiBumiColors.textMuted,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: DynamicGlassDecoration.accentPill(
                            radius: 8,
                            fillColor: WijiBumiColors.lightMint,
                            borderColor: WijiBumiColors.freshLeaf,
                          ),
                          child: Text(
                            order.status,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: WijiBumiColors.deepForest,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Waktu: ${dateFormatter.format(order.createdAt)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: WijiBumiColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.address.fullAddress,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: WijiBumiColors.textSecondary),
                    ),
                    Text(
                      '${order.address.district}, ${order.address.city}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: WijiBumiColors.textPrimary),
                              ),
                              Text(
                                '${item.quantity} ${item.unit} x ${currencyFormatter.format(item.price)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11, color: WijiBumiColors.textCardDark),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            currencyFormatter.format(item.subtotal),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: WijiBumiColors.textCardDark),
                          ),
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
                        const Expanded(
                          child: Text(
                            'Metode Pembayaran',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12, color: WijiBumiColors.textSecondary),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  order.paymentMethod,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: WijiBumiColors.textPrimary,
                                  ),
                                ),
                              ),
                              if (canChangePayment) ...[
                                const SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () => _showChangePaymentSheet(context, orderController, order),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                    decoration: DynamicGlassDecoration.accentPill(
                                      radius: 6,
                                      fillColor: WijiBumiColors.lightMint,
                                    ),
                                    child: const Text(
                                      'Ubah',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: WijiBumiColors.deepForest,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'Subtotal Produk',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12, color: WijiBumiColors.textSecondary),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            currencyFormatter.format(order.subtotal),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: WijiBumiColors.textCardDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'Ongkos Kirim',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12, color: WijiBumiColors.textSecondary),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            order.shippingCost == 0 ? 'Gratis' : currencyFormatter.format(order.shippingCost),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: order.shippingCost == 0 ? WijiBumiColors.success : WijiBumiColors.textCardDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'Total Transaksi',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: WijiBumiColors.textCardDark),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            currencyFormatter.format(order.total),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: WijiBumiColors.textCardDark),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Tombol Ubah Metode Pembayaran jika status belum selesai atau dibatalkan
              if (canChangePayment) ...[
                CustomButton(
                  text: 'Ubah Metode Pembayaran',
                  icon: Icons.payment_rounded,
                  variant: ButtonVariant.secondaryGlass,
                  onPressed: () => _showChangePaymentSheet(context, orderController, order),
                ),
                const SizedBox(height: 12),
              ],

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

  void _showChangePaymentSheet(
    BuildContext context,
    ShopController controller,
    OrderModel order,
  ) {
    Get.bottomSheet(
      ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: WijiBumiColors.surfaceDark.withOpacity(0.96),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withOpacity(0.24),
                  width: 1.2,
                ),
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Pilih Metode Pembayaran',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: WijiBumiColors.textWhite,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Pilih salah satu metode pembayaran yang tersedia',
                      style: TextStyle(
                        fontSize: 12,
                        color: WijiBumiColors.textMutedLight,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...controller.availablePaymentMethods.map((method) {
                      final isSelected = order.paymentMethod == method;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? WijiBumiColors.freshLeaf.withOpacity(0.18)
                              : Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? WijiBumiColors.freshLeaf
                                : Colors.white.withOpacity(0.14),
                            width: 1.0,
                          ),
                        ),
                        child: InkWell(
                          onTap: () async {
                            Get.back();
                            if (!isSelected) {
                              await controller.updatePaymentMethod(order.id, method);
                            }
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_off,
                                  color: isSelected
                                      ? WijiBumiColors.freshLeaf
                                      : WijiBumiColors.textPlaceholder,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    method,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 13,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      color: isSelected
                                          ? WijiBumiColors.textWhite
                                          : WijiBumiColors.textMutedLight,
                                    ),
                                  ),
                                ),
                                if (method.startsWith('COD')) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: DynamicGlassDecoration.accentPill(
                                      radius: 6,
                                      fillColor: WijiBumiColors.lightMint,
                                    ),
                                    child: const Text(
                                      'Langsung Proses',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: WijiBumiColors.deepForest,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
