import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../app.dart';
import '../controllers/shop_controller.dart';
import '../controllers/location_controller.dart';
import '../widgets/custom_button.dart';
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
        locationController.selectedAddress.value = locationController.addresses.first;
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
        title: const Text('Checkout Pesanan'),
      ),
      body: Obx(() {
        final selectedItems =
            cartController.items.where((i) => i.isSelected).toList();
        final subtotal = cartController.getTotalPrice();

        if (cartController.items.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.remove_shopping_cart_outlined,
                    size: 64, color: WijiBumiColors.textMuted),
                const SizedBox(height: 12),
                const Text(
                  'Keranjang belanja Anda kosong.',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: WijiBumiColors.textPrimary),
                ),
                const SizedBox(height: 12),
                CustomButton(
                  text: 'Kembali Belanja',
                  width: 200,
                  onPressed: () => Get.back(),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==========================================
              // KARTU 1: ALAMAT PENGIRIMAN & JARAK GPS (LBS)
              // ==========================================
              const Text(
                'Alamat Pengiriman',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: WijiBumiColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: DynamicGlassDecoration.cleanCard(radius: 14),
                child: Obx(() {
                  final address = locationController.selectedAddress.value;

                  if (address == null) {
                    return Column(
                      children: [
                        const Text(
                          'Belum ada alamat pengiriman terpilih.',
                          style: TextStyle(
                              fontSize: 13, color: WijiBumiColors.textMuted),
                        ),
                        const SizedBox(height: 12),
                        CustomButton(
                          text: '+ Tambah / Pilih Alamat',
                          variant: ButtonVariant.secondaryGlass,
                          height: 40,
                          onPressed: () {
                            Get.toNamed(AppRoutes.ADDRESS);
                          },
                        ),
                      ],
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded,
                              color: WijiBumiColors.deepForest, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${address.recipientName} (${address.phone})',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: WijiBumiColors.textPrimary,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Get.toNamed(AppRoutes.ADDRESS);
                            },
                            child: const Text(
                              'Ganti Alamat',
                              style: TextStyle(
                                fontSize: 12,
                                color: WijiBumiColors.deepForest,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        address.fullAddress,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: WijiBumiColors.textSecondary,
                          height: 1.3,
                        ),
                      ),
                      Text(
                        '${address.district}, ${address.city}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: WijiBumiColors.textMuted,
                        ),
                      ),
                      const Divider(height: 20),
                      // Jarak GPS dan Estimasi Ongkir
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(Icons.near_me_outlined,
                                    size: 16, color: WijiBumiColors.freshLeaf),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    locationController.distanceKm.value > 0
                                        ? 'Jarak Kebun: ${locationController.distanceKm.value.toStringAsFixed(1)} km'
                                        : 'Jarak GPS: Standar Kota',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: WijiBumiColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              locationController.currentShippingCost.value == 0
                                  ? 'Gratis Ongkir'
                                  : currencyFormatter.format(
                                      locationController.currentShippingCost.value),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: locationController.currentShippingCost.value == 0
                                    ? WijiBumiColors.success
                                    : WijiBumiColors.deepForest,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }),
              ),
              const SizedBox(height: 20),

              // ==========================================
              // KARTU 2: DAFTAR ITEM TERPILIH
              // ==========================================
              Text(
                'Ringkasan Produk (${selectedItems.length} Item)',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: WijiBumiColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: DynamicGlassDecoration.cleanCard(radius: 14),
                child: selectedItems.isEmpty
                    ? Column(
                        children: [
                          const Text('Belum ada produk yang dicentang.'),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              cartController.toggleSelectAll(true);
                            },
                            child: const Text('Centang Semua Produk'),
                          ),
                        ],
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: selectedItems.length,
                        separatorBuilder: (_, __) => const Divider(height: 16),
                        itemBuilder: (context, index) {
                          final item = selectedItems[index];
                          return Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: _buildCheckoutItemImage(item.imageUrl),
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
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: WijiBumiColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      '${item.quantity} ${item.unit} x ${currencyFormatter.format(item.price)}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: WijiBumiColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                currencyFormatter.format(item.subtotal),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: WijiBumiColors.deepForest,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
              ),
              const SizedBox(height: 20),

              // ==========================================
              // KARTU 3: METODE PEMBAYARAN & RINCIAN BIAYA
              // ==========================================
              const Text(
                'Metode Pembayaran',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: WijiBumiColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: DynamicGlassDecoration.cleanCard(radius: 14),
                child: Obx(
                  () => Column(
                    children: orderController.availablePaymentMethods.map((method) {
                      final isSelected =
                          orderController.selectedPaymentMethod.value == method;
                      return InkWell(
                        onTap: () {
                          orderController.selectedPaymentMethod.value = method;
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                color: isSelected
                                    ? WijiBumiColors.deepForest
                                    : WijiBumiColors.textMuted,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  method,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? WijiBumiColors.deepForest
                                        : WijiBumiColors.textPrimary,
                                  ),
                                ),
                              ),
                              if (method.startsWith('COD')) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: DynamicGlassDecoration.accentPill(
                                    radius: 6,
                                    fillColor: WijiBumiColors.lightMint,
                                  ),
                                  child: const Text(
                                    'Langsung Proses',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: WijiBumiColors.deepForest),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Rincian Pembayaran
              const Text(
                'Rincian Biaya',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: WijiBumiColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: DynamicGlassDecoration.cleanCard(radius: 14),
                child: Obx(() {
                  final shippingCost =
                      locationController.currentShippingCost.value;
                  final total = subtotal + shippingCost;

                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'Subtotal Produk',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: WijiBumiColors.textSecondary),
                            ),
                          ),
                          const SizedBox(width: 8),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              currencyFormatter.format(subtotal),
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600),
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
                              style: TextStyle(
                                  fontSize: 13,
                                  color: WijiBumiColors.textSecondary),
                            ),
                          ),
                          const SizedBox(width: 8),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              shippingCost == 0
                                  ? 'Gratis'
                                  : currencyFormatter.format(shippingCost),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: shippingCost == 0
                                    ? WijiBumiColors.success
                                    : WijiBumiColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (subtotal >= 200000) ...[
                        const SizedBox(height: 4),
                        const Row(
                          children: [
                            Icon(Icons.check_circle_rounded,
                                size: 14, color: WijiBumiColors.success),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Promo Gratis Ongkir diterapkan (Subtotal ≥ Rp 200.000)',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 11,
                                    color: WijiBumiColors.success,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'Total Tagihan',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: WijiBumiColors.deepForest),
                            ),
                          ),
                          const SizedBox(width: 8),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              currencyFormatter.format(total),
                              style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: WijiBumiColors.deepForest),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }),
              ),
              const SizedBox(height: 28),

              // Tombol Buat Pesanan
              Obx(
                () => CustomButton(
                  text: 'Buat Pesanan Sekarang',
                  icon: Icons.check_circle_outline_rounded,
                  isLoading: orderController.isSubmitting.value,
                  onPressed: () async {
                    // Pastikan ada item yang dipilih
                    var itemsToBuy = cartController.items
                        .where((i) => i.isSelected)
                        .toList();
                    if (itemsToBuy.isEmpty && cartController.items.isNotEmpty) {
                      cartController.toggleSelectAll(true);
                      itemsToBuy = cartController.items.toList();
                    }

                    if (itemsToBuy.isEmpty) {
                      GlassFeedback.showSnackbar(
                        title: 'Keranjang Kosong',
                        message: 'Silakan pilih barang sebelum checkout.',
                        isError: true,
                      );
                      return;
                    }

                    // Pastikan alamat telah terpilih
                    var address = locationController.selectedAddress.value;
                    if (address == null && locationController.addresses.isNotEmpty) {
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
                      shippingCost: locationController.currentShippingCost.value,
                    );

                    if (order != null) {
                      Get.offNamed(AppRoutes.ORDER_SUCCESS, arguments: order);
                    }
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCheckoutItemImage(String url) {
    final cleanUrl = url.trim();
    final fallback = Container(
      width: 44,
      height: 44,
      color: WijiBumiColors.lightMint,
      child: const Icon(Icons.eco, size: 20, color: WijiBumiColors.freshLeaf),
    );

    if (cleanUrl.isEmpty) return fallback;

    if (cleanUrl.startsWith('http://') || cleanUrl.startsWith('https://')) {
      return Image.network(
        cleanUrl,
        width: 44,
        height: 44,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      );
    } else {
      final assetPath = cleanUrl.startsWith('assets/')
          ? cleanUrl
          : 'assets/images/products/$cleanUrl';
      return Image.asset(
        assetPath,
        width: 44,
        height: 44,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      );
    }
  }
}
