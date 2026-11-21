import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../app.dart';
import '../controllers/shop_controller.dart';
import '../widgets/empty_state.dart';

class OrderHistoryView extends StatelessWidget {
  const OrderHistoryView({super.key});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Selesai':
      case 'Dikirim':
        return WijiBumiColors.deepForest;
      case 'Diproses':
      case 'Dikemas':
        return WijiBumiColors.freshLeaf;
      case 'Menunggu Pembayaran':
        return WijiBumiColors.warning;
      case 'Dibatalkan':
        return WijiBumiColors.error;
      default:
        return WijiBumiColors.textMuted;
    }
  }

  Color _getStatusBg(String status) {
    switch (status) {
      case 'Selesai':
      case 'Dikirim':
      case 'Diproses':
      case 'Dikemas':
        return WijiBumiColors.lightMint;
      case 'Menunggu Pembayaran':
        return WijiBumiColors.warning.withOpacity(0.15);
      case 'Dibatalkan':
        return WijiBumiColors.error.withOpacity(0.12);
      default:
        return Colors.grey.shade100;
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderController = Get.find<ShopController>();

    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final dateFormatter = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');

    return Scaffold(
      backgroundColor: WijiBumiColors.backgroundCanvas,
      appBar: AppBar(
        title: const Text('Riwayat Pesanan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          tooltip: 'Kembali ke Beranda',
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Get.offAllNamed(AppRoutes.MAIN);
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
      body: PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) return;
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            Get.offAllNamed(AppRoutes.MAIN);
          }
        },
        child: Obx(() {
          if (orderController.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(WijiBumiColors.freshLeaf),
              ),
            );
          }

          final orders = orderController.orders;

          if (orders.isEmpty) {
            return EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'Belum Ada Pesanan',
              message: 'Anda belum memiliki transaksi pesanan di Wiji Bumi.',
              action: ElevatedButton(
                onPressed: () => Get.offAllNamed(AppRoutes.MAIN),
                child: const Text('Mulai Belanja'),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => orderController.loadOrders(),
            color: WijiBumiColors.deepForest,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final order = orders[index];

                return InkWell(
                  onTap: () {
                    Get.toNamed(AppRoutes.ORDER_DETAIL, arguments: order);
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: DynamicGlassDecoration.cleanCard(radius: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Kartu: No Pesanan & Badge Status Kaca
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              order.orderNumber,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: WijiBumiColors.deepForest,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: DynamicGlassDecoration.accentPill(
                                radius: 8,
                                fillColor: _getStatusBg(order.status),
                                borderColor: _getStatusColor(order.status).withOpacity(0.5),
                              ),
                              child: Text(
                                order.status,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: _getStatusColor(order.status),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Tanggal Pemesanan
                        Text(
                          dateFormatter.format(order.createdAt),
                          style: const TextStyle(
                            fontSize: 11,
                            color: WijiBumiColors.textMuted,
                          ),
                        ),
                        const Divider(height: 18),

                        // Item Ringkas
                        Text(
                          order.items.isNotEmpty
                              ? '${order.items.first.name} (${order.items.first.quantity} ${order.items.first.unit})${order.items.length > 1 ? ' + ${order.items.length - 1} produk lainnya' : ''}'
                              : 'Belanja Produk Pertanian',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: WijiBumiColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Total Belanja & Metode Bayar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              order.paymentMethod,
                              style: const TextStyle(
                                fontSize: 12,
                                color: WijiBumiColors.textSecondary,
                              ),
                            ),
                            Text(
                              currencyFormatter.format(order.total),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: WijiBumiColors.deepForest,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}
