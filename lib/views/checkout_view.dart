import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../app.dart';
import '../controllers/shop_controller.dart';
import '../controllers/location_controller.dart';
import '../widgets/glass_feedback.dart';

class CheckoutView extends StatefulWidget {
  const CheckoutView({super.key});

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cartController = Get.find<ShopController>();
      final locationController = Get.find<LocationController>();

      // Pastikan ada item yang dipilih jika keranjang ada isinya
      if (cartController.items.isNotEmpty &&
          cartController.items.where((i) => i.isSelected).isEmpty) {
        cartController.toggleSelectAll(true);
      }

      // Pastikan alamat utama terpilih
      if (locationController.selectedAddress.value == null &&
          locationController.addresses.isNotEmpty) {
        locationController.selectedAddress.value =
            locationController.addresses.first;
      }

      if (locationController.selectedAddress.value != null) {
        locationController.updateDistanceAndShipping(
          locationController.selectedAddress.value!,
          cartController.getTotalPrice(),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<ShopController>();
    final locationController = Get.find<LocationController>();
    final orderController = Get.find<ShopController>();

    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: WijiBumiColors.backgroundCanvas,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C2B1E),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left_rounded,
            size: 30,
            color: Colors.white,
          ),
          tooltip: 'Kembali',
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Get.back();
            }
          },
        ),
        title: const Text(
          'Checkout Pesanan',
          style: TextStyle(
            fontSize: 16.5,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: Obx(() {
        final selectedItems =
            cartController.items.where((i) => i.isSelected).toList();
        final subtotal = cartController.getTotalPrice();

        if (cartController.items.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.remove_shopping_cart_outlined,
                    size: 64,
                    color: Color(0xFF8C9B8D),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Keranjang belanja Anda kosong.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1C2B1E),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1C2B1E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Kembali Belanja',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==========================================
              // BAGIAN 1: ALAMAT PENGIRIMAN
              // ==========================================
              const Text(
                'Alamat Pengiriman',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                decoration: DynamicGlassDecoration.glassCard(radius: 16),
                padding: const EdgeInsets.all(16),
                child: Obx(() {
                  final address = locationController.selectedAddress.value;

                  if (address == null) {
                    return Column(
                      children: [
                        const Text(
                          'Belum ada alamat pengiriman terpilih.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFFC8DDD0),
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () {
                            Get.toNamed(AppRoutes.ADDRESS);
                          },
                          icon: const Icon(Icons.add_location_alt_outlined, size: 18),
                          label: const Text('Tambah / Pilih Alamat'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFA7F3D0),
                            side: const BorderSide(color: Color(0xFFA7F3D0)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.24),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.location_on_rounded,
                              color: Color(0xFFA7F3D0),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  address.recipientName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  '(${address.phone})',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () {
                              Get.toNamed(AppRoutes.ADDRESS);
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.28),
                                  width: 1,
                                ),
                              ),
                              child: const Text(
                                'Ganti\nAlamat',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFA7F3D0),
                                  height: 1.15,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        address.fullAddress.isNotEmpty
                            ? (address.district.isNotEmpty
                                ? '${address.fullAddress}, ${address.district}, ${address.city}'
                                : address.fullAddress)
                            : 'Jl. Kemang Raya No. 12 RT 04/RW 02, Mampang Prapatan, Jakarta Selatan',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFC8DDD0),
                          height: 1.4,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(
                          color: Color(0x26FFFFFF),
                          height: 1,
                          thickness: 1,
                        ),
                      ),
                      // Jarak GPS dan Estimasi Ongkir
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.map_outlined,
                                size: 16,
                                color: Color(0xFFA7F3D0),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                locationController.distanceKm.value > 0
                                    ? 'Jarak Kebun: ${locationController.distanceKm.value.toStringAsFixed(1)} km'
                                    : 'Jarak Kebun: 5.1 km',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFFC8DDD0),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            locationController.currentShippingCost.value == 0
                                ? 'Gratis'
                                : currencyFormatter.format(
                                    locationController.currentShippingCost.value,
                                  ),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }),
              ),
              const SizedBox(height: 18),

              // ==========================================
              // BAGIAN 2: RINGKASAN PRODUK
              // ==========================================
              Text(
                'Ringkasan Produk (${selectedItems.length} Item)',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                decoration: DynamicGlassDecoration.glassCard(radius: 16),
                padding: const EdgeInsets.all(16),
                child: selectedItems.isEmpty
                    ? Column(
                        children: [
                          const Text(
                            'Belum ada produk yang dicentang.',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFFC8DDD0),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              cartController.toggleSelectAll(true);
                            },
                            child: const Text(
                              'Centang Semua Produk',
                              style: TextStyle(color: Color(0xFFA7F3D0)),
                            ),
                          ),
                        ],
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: selectedItems.length,
                        separatorBuilder: (_, __) => const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Divider(
                            color: Color(0x26FFFFFF),
                            height: 1,
                            thickness: 1,
                          ),
                        ),
                        itemBuilder: (context, index) {
                          final item = selectedItems[index];
                          return Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.24),
                                    width: 1,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: _buildCheckoutItemImage(
                                    item.imageUrl,
                                    item.name,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${item.quantity} ${item.unit} × ${currencyFormatter.format(item.price)}',
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        color: Color(0xFFC8DDD0),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                currencyFormatter.format(item.subtotal),
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
              ),
              const SizedBox(height: 18),

              // ==========================================
              // BAGIAN 3: METODE PEMBAYARAN
              // ==========================================
              const Text(
                'Metode Pembayaran',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                decoration: DynamicGlassDecoration.glassCard(radius: 16),
                padding: const EdgeInsets.all(12),
                child: Obx(
                  () => Column(
                    children: orderController.availablePaymentMethods.map((method) {
                      final isSelected =
                          orderController.selectedPaymentMethod.value == method;
                      final isCod = method.toUpperCase().contains('COD');

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: () {
                            orderController.selectedPaymentMethod.value = method;
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF2E7D32).withOpacity(0.35)
                                  : Colors.white.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFFA7F3D0)
                                    : Colors.white.withOpacity(0.14),
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_off,
                                  color: isSelected
                                      ? const Color(0xFFA7F3D0)
                                      : const Color(0xFF9EB5A4),
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF2E7D32).withOpacity(0.5)
                                        : Colors.white.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    _getPaymentIcon(method),
                                    size: 18,
                                    color: isSelected
                                        ? const Color(0xFFA7F3D0)
                                        : const Color(0xFFC8DDD0),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    method,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w600,
                                      color: isSelected ? Colors.white : const Color(0xFFC8DDD0),
                                    ),
                                  ),
                                ),
                                if (isCod) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2E7D32).withOpacity(0.35),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: const Color(0xFFA7F3D0).withOpacity(0.5),
                                        width: 1,
                                      ),
                                    ),
                                    child: const Text(
                                      'Langsung\nProses',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFFA7F3D0),
                                        height: 1.15,
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
              ),
              const SizedBox(height: 18),

              // ==========================================
              // BAGIAN 4: RINCIAN BIAYA
              // ==========================================
              const Text(
                'Rincian Biaya',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                decoration: DynamicGlassDecoration.glassCard(radius: 16),
                padding: const EdgeInsets.all(16),
                child: Obx(() {
                  final shippingCost =
                      locationController.currentShippingCost.value;
                  final total = subtotal + shippingCost;

                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Subtotal Produk',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFFC8DDD0),
                            ),
                          ),
                          Text(
                            currencyFormatter.format(subtotal),
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Ongkos Kirim',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFFC8DDD0),
                            ),
                          ),
                          Text(
                            shippingCost == 0
                                ? 'Gratis'
                                : currencyFormatter.format(shippingCost),
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(
                          color: Color(0x26FFFFFF),
                          height: 1,
                          thickness: 1,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Tagihan',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Sudah termasuk PPN',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  color: Color(0xFFC8DDD0),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            currencyFormatter.format(total),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }),
              ),
              const SizedBox(height: 24),

              // ==========================================
              // TOMBOL AKSI UTAMA
              // ==========================================
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: orderController.isSubmitting.value
                        ? null
                        : () async {
                            var itemsToBuy = cartController.items
                                .where((i) => i.isSelected)
                                .toList();
                            if (itemsToBuy.isEmpty &&
                                cartController.items.isNotEmpty) {
                              cartController.toggleSelectAll(true);
                              itemsToBuy = cartController.items.toList();
                            }

                            if (itemsToBuy.isEmpty) {
                              GlassFeedback.showSnackbar(
                                title: 'Keranjang Kosong',
                                message:
                                    'Silakan pilih barang sebelum checkout.',
                                isError: true,
                              );
                              return;
                            }

                            var address =
                                locationController.selectedAddress.value;
                            if (address == null &&
                                locationController.addresses.isNotEmpty) {
                              address = locationController.addresses.first;
                              locationController.selectedAddress.value = address;
                            }

                            if (address == null) {
                              GlassFeedback.showSnackbar(
                                title: 'Alamat Belum Terisi',
                                message:
                                    'Silakan isi atau pilih alamat pengiriman Anda terlebih dahulu.',
                                isError: true,
                              );
                              Get.toNamed(AppRoutes.ADDRESS);
                              return;
                            }

                            final order = await orderController.placeOrder(
                              address: address,
                              selectedItems: itemsToBuy,
                              shippingCost: locationController
                                  .currentShippingCost.value,
                            );

                            if (order != null) {
                              Get.offNamed(
                                AppRoutes.ORDER_SUCCESS,
                                arguments: order,
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA7F3D0),
                      disabledBackgroundColor:
                          const Color(0xFFA7F3D0).withOpacity(0.4),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: orderController.isSubmitting.value
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Color(0xFF142117),
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                color: Color(0xFF142117),
                                size: 22,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Buat Pesanan Sekarang',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF142117),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  IconData _getPaymentIcon(String method) {
    final lower = method.toLowerCase();
    if (lower.contains('transfer') || lower.contains('bank')) {
      return Icons.account_balance_outlined;
    }
    if (lower.contains('wallet') ||
        lower.contains('gopay') ||
        lower.contains('ovo') ||
        lower.contains('shopeepay')) {
      return Icons.credit_card_outlined;
    }
    return Icons.payments_outlined;
  }

  Widget _buildCheckoutItemImage(String url, String name) {
    final cleanUrl = url.trim();
    Widget fallback;
    final lowerName = name.toLowerCase();
    if (lowerName.contains('belimbing')) {
      fallback = const Icon(
        Icons.star_rounded,
        size: 28,
        color: Color(0xFFF59E0B),
      );
    } else if (lowerName.contains('apel')) {
      fallback = const Icon(
        Icons.apple_rounded,
        size: 26,
        color: Color(0xFFE53935),
      );
    } else {
      fallback = const Icon(
        Icons.eco_rounded,
        size: 24,
        color: Color(0xFF38A169),
      );
    }

    if (cleanUrl.isEmpty) return fallback;

    if (cleanUrl.startsWith('http://') || cleanUrl.startsWith('https://')) {
      return Image.network(
        cleanUrl,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      );
    } else {
      final assetPath = cleanUrl.startsWith('assets/')
          ? cleanUrl
          : 'assets/images/products/$cleanUrl';
      return Image.asset(
        assetPath,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      );
    }
  }
}
