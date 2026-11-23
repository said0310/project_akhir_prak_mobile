import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app.dart';
import '../controllers/shop_controller.dart';
import '../widgets/empty_state.dart';
import '../widgets/product_card.dart';

class WishlistView extends StatelessWidget {
  const WishlistView({super.key});

  @override
  Widget build(BuildContext context) {
    final shopController = Get.find<ShopController>();

    return Scaffold(
      backgroundColor: WijiBumiColors.backgroundCanvas,
      appBar: AppBar(
        backgroundColor: WijiBumiColors.deepForest,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 30, color: Colors.white),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Get.back();
            }
          },
        ),
        title: const Text(
          'Produk Favorit (Wishlist)',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Obx(() {
        final items = shopController.wishlistItems;

        if (items.isEmpty) {
          return EmptyState(
            icon: Icons.favorite_border_rounded,
            title: 'Wishlist Masih Kosong',
            message: 'Simpan produk sayuran atau tanaman hias favoritmu dengan menekan ikon hati di detail produk.',
            action: ElevatedButton(
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Get.back();
                } else {
                  Get.offAllNamed(AppRoutes.MAIN);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA7F3D0),
                foregroundColor: const Color(0xFF142117),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Jelajahi Produk',
                style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF142117)),
              ),
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
          physics: const BouncingScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 16,
            childAspectRatio: 0.70,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final product = items[index];
            return ProductCard(
              product: product,
              onQuickAdd: () {
                shopController.addToCart(product, 1);
              },
            );
          },
        );
      }),
    );
  }
}
