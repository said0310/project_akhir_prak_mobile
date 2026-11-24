import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app.dart';
import '../controllers/shop_controller.dart';
import '../controllers/location_controller.dart';
import '../models/models.dart';
import '../widgets/custom_button.dart';
import '../widgets/glass_feedback.dart';
import '../widgets/google_map_widget.dart';

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
                const Icon(
                  Icons.remove_shopping_cart_outlined,
                  size: 64,
                  color: WijiBumiColors.textMuted,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Keranjang belanja Anda kosong.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'Kembali Belanja',
                  width: 200,
                  onPressed: () => Get.back(),
                ),
              ],
            ),
          );
        }

        final shippingCost = locationController.currentShippingCost.value;
        final total = subtotal + shippingCost;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Alamat Pengiriman & Jarak GPS (LBS)
              _buildSectionHeader('Alamat Pengiriman'),
              const SizedBox(height: 8),
              _buildAddressSection(locationController, subtotal),
              const SizedBox(height: 20),

              // 2. Daftar Item Terpilih
              _buildSectionHeader('Ringkasan Produk (${selectedItems.length} Item)'),
              const SizedBox(height: 8),
              _buildProductSummarySection(selectedItems, cartController),
              const SizedBox(height: 20),

              // 3. Metode Pembayaran
              _buildSectionHeader('Metode Pembayaran'),
              const SizedBox(height: 8),
              _buildPaymentMethodSection(orderController),
              const SizedBox(height: 20),

              // 4. Rincian Biaya
              _buildSectionHeader('Rincian Biaya'),
              const SizedBox(height: 8),
              _buildCostBreakdownSection(subtotal, shippingCost, total),
              const SizedBox(height: 28),

              // 5. Tombol Buat Pesanan
              _buildCheckoutButton(cartController, locationController, orderController),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    );
  }

  Widget _buildAddressSection(LocationController locationController, double subtotal) {
    return LiquidGlassCard(
      padding: const EdgeInsets.all(16),
      radius: 14,
      child: Obx(() {
        final address = locationController.selectedAddress.value;

        if (address == null) {
          return Column(
            children: [
              const Text(
                'Belum ada alamat pengiriman terpilih.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: Color(0xFFC8DDD0),
                ),
              ),
              const SizedBox(height: 12),
              CustomButton(
                text: '+ Tambah / Pilih Alamat',
                variant: ButtonVariant.secondaryGlass,
                height: 40,
                onPressed: () => Get.toNamed(AppRoutes.ADDRESS),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  color: Color(0xFFA7F3D0),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
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
                ),
                TextButton(
                  onPressed: () => Get.toNamed(AppRoutes.ADDRESS),
                  child: const Text(
                    'Ganti Alamat',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: Color(0xFFA7F3D0),
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
                fontFamily: 'Poppins',
                fontSize: 12,
                color: Color(0xFFC8DDD0),
                height: 1.3,
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
            const Divider(height: 20),

            // Peta Google Maps Rute Cabang Toko
            if (address.latitude != 0 || address.longitude != 0) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '🗺️ Rute Cabang Toko',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Obx(() => Text(
                          locationController.selectedStore.value.name,
                          textAlign: TextAlign.end,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFA7F3D0),
                          ),
                        )),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Obx(() => GoogleMapWidget(
                    userLatitude: address.latitude,
                    userLongitude: address.longitude,
                    userMarkerTitle: 'Lokasi Pengiriman',
                    userMarkerSnippet: address.fullAddress,
                    height: 220,
                    showStoreMarker: true,
                    showPolyline: true,
                    isPickerMode: false,
                    selectedBranch: locationController.selectedStore.value,
                    onBranchChanged: (branch) {
                      locationController.setStoreBranch(branch, subtotal);
                    },
                  )),
              const SizedBox(height: 10),
            ],

            // Jarak GPS dan Estimasi Ongkir
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.near_me_outlined,
                        size: 16,
                        color: Color(0xFFA7F3D0),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Obx(() {
                          final label = locationController.distanceLabel.value;
                          final km = locationController.distanceKm.value;
                          return Text(
                            label.isNotEmpty
                                ? '📍 $label'
                                : km > 0
                                    ? 'Jarak Kebun: ${km.toStringAsFixed(1)} km'
                                    : 'Jarak GPS: Standar Kota',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          );
                        }),
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
                        : WijiBumiFormat.currency(
                            locationController.currentShippingCost.value),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: locationController.currentShippingCost.value == 0
                          ? const Color(0xFF4ADE80)
                          : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }

  Widget _buildProductSummarySection(
      List<CartItemModel> selectedItems, ShopController cartController) {
    return LiquidGlassCard(
      padding: const EdgeInsets.all(14),
      radius: 14,
      child: selectedItems.isEmpty
          ? Column(
              children: [
                const Text(
                  'Belum ada produk yang dicentang.',
                  style: TextStyle(fontFamily: 'Poppins', color: Color(0xFFC8DDD0)),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => cartController.toggleSelectAll(true),
                  child: const Text(
                    'Centang Semua Produk',
                    style: TextStyle(fontFamily: 'Poppins', color: Color(0xFFA7F3D0)),
                  ),
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
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '${item.quantity} ${item.unit} x ${WijiBumiFormat.currency(item.price)}',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              color: Color(0xFFC8DDD0),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      WijiBumiFormat.currency(item.subtotal),
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildPaymentMethodSection(ShopController orderController) {
    return LiquidGlassCard(
      padding: const EdgeInsets.all(14),
      radius: 14,
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
                          ? const Color(0xFFA7F3D0)
                          : const Color(0xFFC8DDD0),
                      size: 18,
                    ),
                    const SizedBox(width: 10),
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
                              ? const Color(0xFFA7F3D0)
                              : Colors.white,
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
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCostBreakdownSection(
      double subtotal, double shippingCost, double total) {
    return LiquidGlassCard(
      padding: const EdgeInsets.all(14),
      radius: 14,
      child: Column(
        children: [
          CostDetailRow(
            label: 'Subtotal Produk',
            value: WijiBumiFormat.currency(subtotal),
          ),
          const SizedBox(height: 8),
          CostDetailRow(
            label: 'Ongkos Kirim',
            value: shippingCost == 0
                ? 'Gratis'
                : WijiBumiFormat.currency(shippingCost),
            valueColor: shippingCost == 0
                ? const Color(0xFF4ADE80)
                : Colors.white,
          ),
          if (subtotal >= 200000) ...[
            const SizedBox(height: 6),
            const Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: 14,
                  color: Color(0xFF4ADE80),
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Promo Gratis Ongkir diterapkan (Subtotal ≥ Rp 200.000)',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: Color(0xFF4ADE80),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const Divider(height: 20),
          CostDetailRow(
            label: 'Total Tagihan',
            value: WijiBumiFormat.currency(total),
            isBold: true,
            fontSize: 16,
            valueColor: const Color(0xFFA7F3D0),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutButton(
      ShopController cartController,
      LocationController locationController,
      ShopController orderController) {
    return Obx(
      () => CustomButton(
        text: 'Buat Pesanan Sekarang',
        icon: Icons.check_circle_outline_rounded,
        isLoading: orderController.isSubmitting.value,
        onPressed: () async {
          var itemsToBuy =
              cartController.items.where((i) => i.isSelected).toList();
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
    );
  }

  Widget _buildCheckoutItemImage(String url) {
    final cleanUrl = url.trim();
    final fallback = Container(
      width: 44,
      height: 44,
      color: WijiBumiColors.lightMint,
      child: const Icon(Icons.eco, size: 20, color: Color(0xFFA7F3D0)),
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
