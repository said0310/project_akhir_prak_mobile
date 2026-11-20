import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/product_model.dart';
import '../../../storage/hive_service.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/product_card.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../main/controllers/main_controller.dart';

class WishlistView extends StatelessWidget {
  const WishlistView({super.key});

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();
    final mainController = Get.find<MainController>();

    return Scaffold(
      backgroundColor: WijiBumiColors.backgroundCanvas,
      appBar: AppBar(
        title: const Text('Produk Favorit (Wishlist)'),
      ),
      // Sesuai PRD Bagian 15 & 22: ValueListenableBuilder wajib dipakai untuk mendengarkan perubahan Hive wishlistBox
      body: ValueListenableBuilder<Box<ProductModel>>(
        valueListenable: HiveService.wishlistBox.listenable(),
        builder: (context, box, _) {
          final items = box.values.toList();

          if (items.isEmpty) {
            return EmptyState(
              icon: Icons.favorite_border_rounded,
              title: 'Wishlist Masih Kosong',
              message: 'Simpan produk sayuran atau tanaman hias favoritmu dengan menekan ikon hati di detail produk.',
              action: ElevatedButton(
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Get.back();
                  }
                  mainController.changeTab(0); // Ke Beranda
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
                  cartController.addToCart(product, 1);
                },
              );
            },
          );
        },
      ),
    );
  }
}
