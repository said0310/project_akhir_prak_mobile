import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../app.dart';
import '../models/models.dart';
import '../controllers/shop_controller.dart';
import '../controllers/auth_controller.dart';

class OrderSuccessView extends StatelessWidget {
  const OrderSuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    // Ambil order dari arguments navigasi GetX
    OrderModel? order = Get.arguments is OrderModel ? Get.arguments as OrderModel : null;

    // Fallback: ambil order terakhir dari ShopController jika ada
    if (order == null && Get.isRegistered<ShopController>()) {
      final shopCtrl = Get.find<ShopController>();
      order = shopCtrl.currentOrder.value ?? (shopCtrl.orders.isNotEmpty ? shopCtrl.orders.first : null);
    }

    // Fallback sample data dinamis agar pratinjau selalu tampil sempurna
    final currentUserName = Get.isRegistered<AuthController>()
        ? (Get.find<AuthController>().currentUser.value?.name ?? 'Pengguna')
        : 'Pengguna';

    order ??= OrderModel(
      id: 'ord_sample',
      orderNumber: 'WB-${DateFormat('yyyyMMdd').format(DateTime.now())}-2567',
      userId: 'user_1',
      createdAt: DateTime.now(),
      status: 'Menunggu Pembayaran',
      paymentMethod: 'COD (Bayar di Tempat)',
      address: AddressModel(
        id: 'addr_1',
        userId: 'user_1',
        recipientName: currentUserName,
        phone: '081234567890',
        fullAddress: 'Jl. Kaliurang Km 5.6 No. 18, Sleman, DIY',
        city: 'Sleman',
        district: 'Depok',
        latitude: -7.7620,
        longitude: 110.3800,
      ),
      subtotal: 36500,
      shippingCost: 0,
      total: 36500,
      items: [
        OrderItemModel(productId: 'p1', name: 'Bayam Organik Segar', price: 7000, unit: 'ikat', quantity: 2, subtotal: 14000),
        OrderItemModel(productId: 'p12', name: 'Tomat Ceri Hidroponik', price: 12500, unit: 'pack (250g)', quantity: 1, subtotal: 12500),
        OrderItemModel(productId: 'p4', name: 'Wortel Manis Brastagi', price: 10000, unit: 'pack (500g)', quantity: 1, subtotal: 10000),
      ],
    );

    final finalOrder = order;
    final formattedDate = _formatTransactionTime(finalOrder.createdAt);

    return Scaffold(
      backgroundColor: const Color(0xFFEAF2EB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEAF2EB),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 30, color: Color(0xFF1C2B1E)),
          onPressed: () {
            Get.offAllNamed(AppRoutes.MAIN);
          },
        ),
        title: const Text(
          'Konfirmasi Pesanan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1C2B1E),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            children: [
              // ==========================================
              // 1. BAGIAN HEADER SUKSES (LINGKARAN CENTANG)
              // ==========================================
              const SizedBox(height: 8),
              Center(
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: const Color(0xFF38A169).withOpacity(0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: Color(0xFF38A169),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 34,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Pesanan Berhasil Dibuat!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  color: Color(0xFF1C2B1E),
                ),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Terima kasih! Pesanan Anda telah diterima dan segera disiapkan oleh petani mitra kami.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.45,
                    color: Color(0xFF5A6E5D),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(height: 22),

              // ==========================================
              // 2. KARTU STRUK TRANSAKSI DIGITAL
              // ==========================================
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // --- HEADER STRUK ---
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 24, 20, 14),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.eco_rounded,
                                size: 20,
                                color: Color(0xFF38A169),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'WIJI BUMI',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                  color: Color(0xFF1C2B1E),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6),
                          Text(
                            'STRUK TRANSAKSI DIGITAL',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2.2,
                              color: Color(0xFF7A8B7C),
                            ),
                          ),
                          SizedBox(height: 16),
                          Divider(height: 1, thickness: 0.8, color: Color(0xFFEAF0EB)),
                        ],
                      ),
                    ),

                    // --- INFORMASI TRANSAKSI (2 KOLOM) ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            label: 'Nomor Pesanan',
                            customValueWidget: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F7F4),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFFD6E2D8), width: 0.8),
                              ),
                              child: Text(
                                finalOrder.orderNumber,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1C2B1E),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            label: 'Waktu Transaksi',
                            value: formattedDate,
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            label: 'Metode Pembayaran',
                            value: finalOrder.paymentMethod,
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            label: 'Status Pembayaran',
                            customValueWidget: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7).withOpacity(0.7),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFF59E0B).withOpacity(0.5),
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                finalOrder.status,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFB45309),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),

                    // --- PEMISAH SOBEKAN TIKET (TICKET PERFORATION) ---
                    _buildTicketPerforation(),

                    // --- RINCIAN PESANAN ---
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(
                                child: Text(
                                  'RINCIAN PESANAN',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.6,
                                    color: Color(0xFF5A6E5D),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE6F4EA),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${finalOrder.items.length} Macam Produk',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2E7D32),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Daftar Produk yang Dibeli
                          ...finalOrder.items.map((item) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          style: const TextStyle(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF1C2B1E),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${item.quantity} ${item.unit} × ${currencyFormatter.format(item.price)}',
                                          style: const TextStyle(
                                            fontSize: 11.5,
                                            color: Color(0xFF7A8B7C),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      currencyFormatter.format(item.subtotal),
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1C2B1E),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),

                          const SizedBox(height: 6),
                          const Divider(height: 1, thickness: 0.8, color: Color(0xFFEAF0EB)),
                          const SizedBox(height: 14),

                          // Subtotal Produk
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Subtotal Produk',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: Color(0xFF7A8B7C),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  currencyFormatter.format(finalOrder.subtotal),
                                  textAlign: TextAlign.end,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1C2B1E),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Biaya Pengiriman
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Biaya Pengiriman',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: Color(0xFF7A8B7C),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: finalOrder.shippingCost == 0
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE6F4EA),
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        child: const Text(
                                          'GRATIS',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF2E7D32),
                                          ),
                                        ),
                                      )
                                    : Text(
                                        currencyFormatter.format(finalOrder.shippingCost),
                                        textAlign: TextAlign.end,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF1C2B1E),
                                        ),
                                      ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),
                          const Divider(height: 1, thickness: 0.8, color: Color(0xFFEAF0EB)),
                          const SizedBox(height: 14),

                          // Total Tagihan
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 2),
                                child: Text(
                                  'Total Tagihan',
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF1C2B1E),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        currencyFormatter.format(finalOrder.total),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFF1C2B1E),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'Sudah termasuk PPN',
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        color: Color(0xFF7A8B7C),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),
                          const Divider(height: 1, thickness: 0.8, color: Color(0xFFEAF0EB)),
                          const SizedBox(height: 20),

                          // Barcode Digital Native
                          _buildBarcode(finalOrder.orderNumber),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // ==========================================
              // 3. KETERANGAN TAMBAHAN & TOMBOL AKSI
              // ==========================================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.monetization_on_outlined,
                      size: 16,
                      color: Color(0xFF38A169),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        finalOrder.paymentMethod.toUpperCase().contains('COD')
                            ? 'Siapkan uang pas saat kurir tiba di lokasi Anda.'
                            : 'Selesaikan pembayaran sebelum batas waktu berakhir.',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF5A6E5D),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Tombol Utama: Lihat Rincian Pesanan
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1C2B1E),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    // Pastikan order tersimpan di currentOrder dan navigasi ke detail
                    if (Get.isRegistered<ShopController>()) {
                      Get.find<ShopController>().currentOrder.value = finalOrder;
                    }
                    Get.toNamed(AppRoutes.ORDER_DETAIL, arguments: finalOrder);
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Lihat Rincian Pesanan',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 18,
                        color: Color(0xFF38A169),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Tombol Sekunder: Kembali ke Beranda
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1C2B1E),
                    elevation: 0,
                    side: const BorderSide(color: Color(0xFFD6E2D8), width: 1.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Get.offAllNamed(AppRoutes.MAIN);
                  },
                  child: const Text(
                    'Kembali ke Beranda',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1C2B1E),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  /// Format waktu transaksi: 23 Nov 2026 • 18:05 WIB
  String _formatTransactionTime(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final day = dt.day;
    final month = months[dt.month - 1];
    final year = dt.year;
    final hour = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$day $month $year • $hour:$min WIB';
  }

  /// Baris informasi 2 kolom responsif (aman dari overflow)
  Widget _buildInfoRow({
    required String label,
    String? value,
    Widget? customValueWidget,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.5,
            color: Color(0xFF7A8B7C),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: customValueWidget ??
              Text(
                value ?? '-',
                textAlign: TextAlign.end,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1C2B1E),
                ),
              ),
        ),
      ],
    );
  }

  /// Pemisah sobekan tiket (tiket perforation) dengan 2 lekukan setengah lingkaran di sisi tepi
  Widget _buildTicketPerforation() {
    return SizedBox(
      height: 24,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Garis Putus-putus Horizontal
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final boxWidth = constraints.maxWidth;
                const dashWidth = 4.0;
                const dashSpace = 4.0;
                final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
                return ClipRect(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(dashCount, (_) {
                      return const SizedBox(
                        width: dashWidth,
                        height: 1.2,
                        child: DecoratedBox(
                          decoration: BoxDecoration(color: Color(0xFFD6E2D8)),
                        ),
                      );
                    }),
                  ),
                );
              },
            ),
          ),
          // Lekukan Setengah Lingkaran Sisi Kiri
          Positioned(
            left: -12,
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Color(0xFFEAF2EB), // Senada dengan latar belakang
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Lekukan Setengah Lingkaran Sisi Kanan
          Positioned(
            right: -12,
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Color(0xFFEAF2EB), // Senada dengan latar belakang
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Ilustrasi Barcode Native Flutter (tanpa package eksternal, auto-scale aman dari overflow)
  Widget _buildBarcode(String orderNumber) {
    const barWidths = [
      2, 1, 3, 1, 1, 2, 4, 1, 2, 1, 3, 2, 1, 1, 4, 1, 2, 3, 1, 1,
      2, 1, 3, 1, 2, 4, 1, 2, 1, 3, 1, 2, 1, 4, 2, 1, 3, 1, 2, 1,
      3, 2, 1, 1, 2, 4, 1
    ];

    // Format kode barcode bawah, contoh: WB-2567-ORGANIC
    final parts = orderNumber.split('-');
    final suffixCode = parts.length >= 3 ? parts[2] : (parts.length >= 2 ? parts[1] : orderNumber);
    final barcodeText = 'WB-$suffixCode-ORGANIC';

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        children: [
          SizedBox(
            height: 44,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: barWidths.map((w) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 0.9),
                  width: w * 1.2,
                  color: const Color(0xFF1C2B1E),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            barcodeText.toUpperCase(),
            style: const TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.2,
              color: Color(0xFF7A8B7C),
            ),
          ),
        ],
      ),
    );
  }
}
