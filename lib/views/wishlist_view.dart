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
        title: const Text('Produk Favorit (Wishlist)'),
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
              child: const Text('Jelajahi Produk'),
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
          physics: const BouncingScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.72,
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
