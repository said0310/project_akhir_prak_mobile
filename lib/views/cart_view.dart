import 'dart:ui';
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
        title: const Text('Keranjang Belanja'),
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
                  fontSize: 12,
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
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 140),
              physics: const BouncingScrollPhysics(),
              itemCount: items.length + 1,
              itemBuilder: (context, index) {
                // Header "Pilih Semua"
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: DynamicGlassDecoration.cleanCard(radius: 12),
                      child: Row(
                        children: [
                          Checkbox(
                            value: allSelected,
                            activeColor: WijiBumiColors.deepForest,
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
                                color: WijiBumiColors.textCardDark,
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
                              color: Color(0xFF1B3320),
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
                    decoration: DynamicGlassDecoration.cleanCard(radius: 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Checkbox Beli per Item
                        Checkbox(
                          value: item.isSelected,
                          activeColor: WijiBumiColors.deepForest,
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
                                  color: WijiBumiColors.textCardDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${currencyFormatter.format(item.price)} /${item.unit}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0C2411),
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Tombol - / + dan Hapus
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Kontrol Kuantitas
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.55),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.4),
                                        width: 1,
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
                                            child: const Icon(Icons.remove, size: 14, color: WijiBumiColors.textCardDark),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 10),
                                          child: Text(
                                            '${item.quantity}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: WijiBumiColors.textCardDark,
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
                                            child: const Icon(Icons.add, size: 14, color: WijiBumiColors.textCardDark),
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

            // 3. Panel Kaca Bawah: Total & Tombol Checkout
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: DynamicGlassDecoration.glassBar(
                      radius: 20,
                      fullTopRadius: true,
                      fullBottomRadius: false,
                    ),
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
                                    color: WijiBumiColors.textMutedLight,
                                  ),
                                ),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    currencyFormatter.format(cartController.getTotalPrice()),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: WijiBumiColors.textWhite,
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
