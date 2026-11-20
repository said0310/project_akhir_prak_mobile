import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/theme/app_theme.dart';
import '../modules/cart/controllers/cart_controller.dart';
import '../app/routes/app_routes.dart';

class CartBadge extends StatelessWidget {
  final VoidCallback? onTap;

  const CartBadge({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ??
          () {
            Get.toNamed(AppRoutes.CART);
          },
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: WijiBumiColors.lightMint.withOpacity(0.9),
          shape: BoxShape.circle,
          border: Border.all(
            color: WijiBumiColors.softSage.withOpacity(0.6),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: WijiBumiColors.deepForest.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(
              Icons.shopping_bag_outlined,
              color: WijiBumiColors.deepForest,
              size: 22,
            ),
            // Reaktif Obx membaca CartController.totalItemCount
            GetX<CartController>(
              builder: (controller) {
                final count = controller.totalItemCount;
                if (count == 0) return const SizedBox.shrink();

                return Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: WijiBumiColors.deepForest,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Center(
                      child: Text(
                        count > 99 ? '99+' : '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
