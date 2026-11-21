import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../app.dart';
import '../controllers/shop_controller.dart';
import '../models/models.dart';
import '../widgets/empty_state.dart';

class OrderHistoryView extends StatefulWidget {
  final bool isEmbedded;
  const OrderHistoryView({super.key, this.isEmbedded = false});

  @override
  State<OrderHistoryView> createState() => _OrderHistoryViewState();
}

class _OrderHistoryViewState extends State<OrderHistoryView> {
  String _selectedStatus = 'Semua';

  final List<Map<String, dynamic>> _filterCategories = [
    {'status': 'Semua', 'label': 'Semua', 'icon': Icons.all_inbox_rounded},
    {'status': 'Menunggu Pembayaran', 'label': 'Belum Bayar', 'icon': Icons.schedule_rounded},
    {'status': 'Diproses', 'label': 'Diproses', 'icon': Icons.inventory_2_outlined},
    {'status': 'Dikirim', 'label': 'Dikirim', 'icon': Icons.local_shipping_outlined},
    {'status': 'Selesai', 'label': 'Selesai', 'icon': Icons.check_circle_outline_rounded},
    {'status': 'Dibatalkan', 'label': 'Dibatalkan', 'icon': Icons.cancel_outlined},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<ShopController>().loadOrders();
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Selesai':
        return WijiBumiColors.success;
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
        return WijiBumiColors.lightMint;
      case 'Dikirim':
        return WijiBumiColors.lightMint;
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

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Selesai':
        return Icons.check_circle_rounded;
      case 'Dikirim':
        return Icons.local_shipping_rounded;
      case 'Diproses':
      case 'Dikemas':
        return Icons.inventory_2_rounded;
      case 'Menunggu Pembayaran':
        return Icons.schedule_rounded;
      case 'Dibatalkan':
        return Icons.cancel_rounded;
      default:
        return Icons.receipt_long_rounded;
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

    final content = Obx(() {
      if (orderController.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(WijiBumiColors.freshLeaf),
          ),
        );
      }

      final allOrders = orderController.orders;

      // Filter berdasarkan tab status aktif
      final filteredOrders = _selectedStatus == 'Semua'
          ? allOrders
          : (_selectedStatus == 'Diproses'
              ? allOrders.where((o) => o.status == 'Diproses' || o.status == 'Dikemas').toList()
              : allOrders.where((o) => o.status == _selectedStatus).toList());

      return RefreshIndicator(
        onRefresh: () => orderController.loadOrders(),
        color: WijiBumiColors.deepForest,
        child: Column(
          children: [
            // Tab Filter Status Pesanan (Horizontal Scroll)
            _buildStatusFilterBar(allOrders),

            // Daftar Pesanan
            Expanded(
              child: filteredOrders.isEmpty
                  ? (allOrders.isEmpty
                      ? EmptyState(
                          icon: Icons.receipt_long_outlined,
                          title: 'Belum Ada Pesanan',
                          message: 'Anda belum memiliki transaksi pesanan di Wiji Bumi.',
                          action: ElevatedButton(
                            onPressed: () => Get.offAllNamed(AppRoutes.MAIN),
                            child: const Text('Mulai Belanja'),
                          ),
                        )
                      : EmptyState(
                          icon: _getStatusIcon(_selectedStatus),
                          title: 'Tidak Ada Pesanan',
                          message: 'Tidak ada pesanan dengan status "$_selectedStatus".',
                        ))
                  : ListView.separated(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, widget.isEmbedded ? 100 : 32),
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      itemCount: filteredOrders.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final order = filteredOrders[index];

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
                                // Header Kartu: No Pesanan & Badge Status dengan Ikon Pendukung
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        order.orderNumber,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: WijiBumiColors.deepForest,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: DynamicGlassDecoration.accentPill(
                                        radius: 8,
                                        fillColor: _getStatusBg(order.status),
                                        borderColor: _getStatusColor(order.status).withOpacity(0.5),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            _getStatusIcon(order.status),
                                            size: 13,
                                            color: _getStatusColor(order.status),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            order.status,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: _getStatusColor(order.status),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // Tanggal Pemesanan
                                Text(
                                  dateFormatter.format(order.createdAt),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
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
                                    Expanded(
                                      child: Text(
                                        order.paymentMethod,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: WijiBumiColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        currencyFormatter.format(order.total),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: WijiBumiColors.deepForest,
                                        ),
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
            ),
          ],
        ),
      );
    });

    return Scaffold(
      backgroundColor: WijiBumiColors.backgroundCanvas,
      appBar: AppBar(
        title: const Text('Pesanan Saya'),
        automaticallyImplyLeading: !widget.isEmbedded,
        leading: widget.isEmbedded
            ? null
            : IconButton(
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
          if (!widget.isEmbedded)
            IconButton(
              icon: const Icon(Icons.home_rounded),
              tooltip: 'Ke Beranda',
              onPressed: () {
                Get.offAllNamed(AppRoutes.MAIN);
              },
            ),
        ],
      ),
      body: widget.isEmbedded
          ? content
          : PopScope(
              canPop: false,
              onPopInvoked: (didPop) {
                if (didPop) return;
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  Get.offAllNamed(AppRoutes.MAIN);
                }
              },
              child: content,
            ),
    );
  }

  Widget _buildStatusFilterBar(List<OrderModel> allOrders) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: _filterCategories.map((tab) {
            final statusKey = tab['status'] as String;
            final label = tab['label'] as String;
            final icon = tab['icon'] as IconData;
            final isSelected = _selectedStatus == statusKey;

            final count = statusKey == 'Semua'
                ? allOrders.length
                : (statusKey == 'Diproses'
                    ? allOrders.where((o) => o.status == 'Diproses' || o.status == 'Dikemas').length
                    : allOrders.where((o) => o.status == statusKey).length);

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedStatus = statusKey;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? WijiBumiColors.freshLeaf
                        : Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? WijiBumiColors.freshLeaf
                          : Colors.white.withOpacity(0.16),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        size: 15,
                        color: isSelected ? Colors.white : WijiBumiColors.textMutedLight,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? Colors.white : WijiBumiColors.textMutedLight,
                        ),
                      ),
                      if (count > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withOpacity(0.25)
                                : Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$count',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : WijiBumiColors.textMutedLight,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
