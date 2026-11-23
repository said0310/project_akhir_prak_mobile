import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../app.dart';
import '../controllers/shop_controller.dart';
import '../widgets/custom_button.dart';
import '../widgets/empty_state.dart';
import '../widgets/glass_feedback.dart';

class CartView extends StatelessWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<ShopController>();

    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: WijiBumiColors.backgroundCanvas,
      appBar: AppBar(
        backgroundColor: WijiBumiColors.deepForest,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Keranjang Belanja',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Obx(() {
            if (cartController.items.isEmpty) return const SizedBox.shrink();
            return TextButton(
              onPressed: () async {
                final confirm = await GlassFeedback.showConfirmDialog(
                  context: context,
                  title: 'Kosongkan Keranjang?',
                  message: 'Semua item di keranjang belanja Anda akan dihapus.',
                  confirmText: 'Kosongkan',
                  isDestructive: true,
                );
                if (confirm == true) {
                  cartController.clearCart();
                }
              },
              child: const Text(
                'Kosongkan',
                style: TextStyle(
                  color: WijiBumiColors.error,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }),
        ],
      ),
      body: Obx(() {
        final items = cartController.items;

        // 1. Tampilan Keranjang Kosong
        if (items.isEmpty) {
          return EmptyState(
            icon: Icons.shopping_cart_outlined,
            title: 'Keranjang Masih Kosong',
            message: 'Yuk, pilih sayuran segar, buah manis, atau tanaman hias favoritmu!',
            action: CustomButton(
              text: 'Mulai Belanja',
              icon: Icons.storefront_rounded,
              width: 170,
              height: 44,
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Get.back();
                } else {
                  Get.offAllNamed(AppRoutes.MAIN);
                }
              },
            ),
          );
        }

        final allSelected = items.every((i) => i.isSelected);

        return Stack(
          children: [
            // 2. Daftar Item Keranjang
            ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
              physics: const BouncingScrollPhysics(),
              itemCount: items.length + 1,
              itemBuilder: (context, index) {
                // Header "Pilih Semua"
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: DynamicGlassDecoration.glassCard(radius: 14),
                      child: Row(
                        children: [
                          Checkbox(
                            value: allSelected,
                            activeColor: const Color(0xFFA7F3D0),
                            checkColor: const Color(0xFF142117),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            onChanged: (val) {
                              cartController.toggleSelectAll(val ?? false);
                            },
                          ),
                          const Expanded(
                            child: Text(
                              'Pilih Semua Item',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: WijiBumiColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${items.length} Barang',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: WijiBumiColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final item = items[index - 1];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: DynamicGlassDecoration.glassCard(radius: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Checkbox Beli per Item
                        Checkbox(
                          value: item.isSelected,
                          activeColor: const Color(0xFFA7F3D0),
                          checkColor: const Color(0xFF142117),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          onChanged: (val) {
                            cartController.toggleSelection(item.productId, val ?? false);
                          },
                        ),

                        // Foto Kecil 64x64
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            width: 64,
                            height: 64,
                            child: _buildItemImage(item.imageUrl),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Informasi Nama, Harga, dan Kontrol Qty
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: WijiBumiColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${currencyFormatter.format(item.price)} /${item.unit}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: WijiBumiColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Tombol - / + dan Hapus
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Kontrol Kuantitas Liquid Glass
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.22),
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            cartController.updateQuantity(item.productId, item.quantity - 1);
                                          },
                                          borderRadius: BorderRadius.circular(6),
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            child: const Icon(Icons.remove, size: 14, color: Colors.white),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 10),
                                          child: Text(
                                            '${item.quantity}',
                                            style: const TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            cartController.updateQuantity(item.productId, item.quantity + 1);
                                          },
                                          borderRadius: BorderRadius.circular(6),
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            child: const Icon(Icons.add, size: 14, color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Tombol Hapus
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, size: 20, color: WijiBumiColors.error),
                                    onPressed: () {
                                      cartController.removeFromCart(item.productId);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // 3. Panel Bawah: Total & Tombol Checkout
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: DynamicGlassDecoration.glassBar(radius: 20, fullBottomRadius: false),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Harga:',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: WijiBumiColors.textSecondary,
                              ),
                            ),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                currencyFormatter.format(cartController.getTotalPrice()),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: WijiBumiColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      CustomButton(
                        text: 'Checkout (${items.where((i) => i.isSelected).length})',
                        width: 150,
                        height: 44,
                        onPressed: cartController.getTotalPrice() > 0
                            ? () {
                                Get.toNamed(AppRoutes.CHECKOUT);
                              }
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildItemImage(String url) {
    final cleanUrl = url.trim();
    final fallback = Container(
      color: WijiBumiColors.lightMint,
      child: const Icon(Icons.eco_rounded, color: WijiBumiColors.freshLeaf),
    );

    if (cleanUrl.isEmpty) return fallback;

    if (cleanUrl.startsWith('http://') || cleanUrl.startsWith('https://')) {
      return Image.network(
        cleanUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      );
    } else {
      final assetPath = cleanUrl.startsWith('assets/')
          ? cleanUrl
          : 'assets/images/products/$cleanUrl';
      return Image.asset(
        assetPath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      );
    }
  }
}
