import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

    final OrderModel? initialOrder =
        Get.arguments is OrderModel ? Get.arguments as OrderModel : null;

    if (initialOrder == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Pesanan')),
        body: const Center(
          child: Text(
            'Data pesanan tidak ditemukan.',
            style: TextStyle(fontFamily: 'Poppins', color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: WijiBumiColors.backgroundCanvas,
      appBar: AppBar(
        backgroundColor: WijiBumiColors.deepForest,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: const Text(
          'Detail Pesanan',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16.5,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
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
            icon: const Icon(Icons.home_rounded, color: Colors.white),
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

        final canCancel =
            order.status == 'Menunggu Pembayaran' || order.status == 'Diproses';
        final canAdvance =
            order.status != 'Selesai' && order.status != 'Dibatalkan';
        final canChangePayment =
            order.status != 'Selesai' && order.status != 'Dibatalkan';

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Kartu Status Pesanan
              _buildStatusCard(order),
              const SizedBox(height: 16),

              // 2. Kartu Alamat Pengiriman
              _buildSectionTitle('Alamat Pengiriman (Snapshot)'),
              const SizedBox(height: 8),
              _buildAddressCard(order.address),
              const SizedBox(height: 16),

              // 3. Kartu Daftar Produk
              _buildSectionTitle('Daftar Produk'),
              const SizedBox(height: 8),
              _buildProductsCard(order.items),
              const SizedBox(height: 16),

              // 4. Kartu Rincian Biaya & Metode Pembayaran
              _buildSectionTitle('Rincian Biaya & Metode Pembayaran'),
              const SizedBox(height: 8),
              _buildCostAndPaymentCard(context, orderController, order, canChangePayment),
              const SizedBox(height: 24),

              // 5. Tombol Aksi
              _buildActionButtons(
                context,
                orderController,
                order,
                canAdvance,
                canCancel,
                canChangePayment,
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    );
  }

  Widget _buildStatusCard(OrderModel order) {
    return LiquidGlassCard(
      padding: const EdgeInsets.all(16),
      radius: 14,
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
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFC8DDD0),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OrderStatusBadge(status: order.status),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            order.orderNumber,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Waktu: ${WijiBumiFormat.date(order.createdAt, pattern: 'dd MMMM yyyy, HH:mm')}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: Color(0xFFC8DDD0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(AddressModel address) {
    return LiquidGlassCard(
      padding: const EdgeInsets.all(16),
      radius: 14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${address.recipientName} (${address.phone})',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            address.fullAddress,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: Color(0xFFC8DDD0),
            ),
          ),
          Text(
            '${address.district}, ${address.city}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: Color(0xFFC8DDD0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsCard(List<OrderItemModel> items) {
    return LiquidGlassCard(
      padding: const EdgeInsets.all(16),
      radius: 14,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(height: 16),
        itemBuilder: (context, index) {
          final item = items[index];
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
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${item.quantity} ${item.unit} x ${WijiBumiFormat.currency(item.price)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: Color(0xFFC8DDD0),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  WijiBumiFormat.currency(item.subtotal),
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCostAndPaymentCard(
    BuildContext context,
    ShopController orderController,
    OrderModel order,
    bool canChangePayment,
  ) {
    return LiquidGlassCard(
      padding: const EdgeInsets.all(16),
      radius: 14,
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
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Color(0xFFC8DDD0),
                  ),
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
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (canChangePayment) ...[
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => _showChangePaymentSheet(
                            context, orderController, order),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2.5),
                          decoration: DynamicGlassDecoration.accentPill(
                            radius: 6,
                            fillColor: WijiBumiColors.lightMint,
                          ),
                          child: const Text(
                            'Ubah',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFA7F3D0),
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
          CostDetailRow(
            label: 'Subtotal Produk',
            value: WijiBumiFormat.currency(order.subtotal),
            fontSize: 12,
          ),
          const SizedBox(height: 8),
          CostDetailRow(
            label: 'Ongkos Kirim',
            value: order.shippingCost == 0
                ? 'Gratis'
                : WijiBumiFormat.currency(order.shippingCost),
            fontSize: 12,
            valueColor: order.shippingCost == 0
                ? const Color(0xFF4ADE80)
                : Colors.white,
          ),
          const Divider(height: 20),
          CostDetailRow(
            label: 'Total Transaksi',
            value: WijiBumiFormat.currency(order.total),
            isBold: true,
            fontSize: 15,
            valueColor: const Color(0xFFA7F3D0),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    ShopController orderController,
    OrderModel order,
    bool canAdvance,
    bool canCancel,
    bool canChangePayment,
  ) {
    return Column(
      children: [
        if (canChangePayment) ...[
          CustomButton(
            text: 'Ubah Metode Pembayaran',
            icon: Icons.payment_rounded,
            variant: ButtonVariant.secondaryGlass,
            onPressed: () =>
                _showChangePaymentSheet(context, orderController, order),
          ),
          const SizedBox(height: 12),
        ],
        if (canAdvance) ...[
          CustomButton(
            text: 'Lanjutkan Status Pesanan',
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
                message:
                    'Apakah Anda yakin ingin membatalkan pesanan ${order.orderNumber}?',
                confirmText: 'Ya, Batalkan',
                isDestructive: true,
              );
              if (confirm == true) {
                orderController.cancelOrder(order.id);
              }
            },
          ),
      ],
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
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
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
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: Color(0xFFC8DDD0),
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
                              await controller.updatePaymentMethod(
                                  order.id, method);
                            }
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
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
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? WijiBumiColors.textWhite
                                          : const Color(0xFFC8DDD0),
                                    ),
                                  ),
                                ),
                                if (method.startsWith('COD')) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration:
                                        DynamicGlassDecoration.accentPill(
                                      radius: 6,
                                      fillColor: WijiBumiColors.lightMint,
                                    ),
                                    child: const Text(
                                      'Langsung Proses',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFA7F3D0),
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
