import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_theme.dart';
import '../data/models/product_model.dart';
import '../app/routes/app_routes.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onQuickAdd;
  final double? width;
  final double? height;

  const ProductCard({
    super.key,
    required this.product,
    this.onQuickAdd,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final isOutOfStock = product.stock <= 0;
    final cardWidth = width ?? 156.0;
    final cardHeight = height ?? 206.0;

    return GestureDetector(
      onTap: () {
        Get.toNamed(
          '${AppRoutes.PRODUCT}/${product.id}',
          arguments: product,
        );
      },
      child: Container(
        width: cardWidth,
        height: cardHeight,
        decoration: DynamicGlassDecoration.glassCard(radius: 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Padding(
              padding: const EdgeInsets.all(9.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Gambar Produk (Di dalam kotak, tidak timbul keluar)
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Hero(
                            tag: 'product_img_${product.id}',
                            child: _buildPlantImage(product.imageUrl),
                          ),
                        ),

                        // Badge Stok Habis jika ada
                        if (isOutOfStock)
                          Positioned(
                            top: 6,
                            right: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: WijiBumiColors.error,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Habis',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // 2. Footer: Nama Produk, Harga (kiri) & Tombol '+' (kanan)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              product.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: WijiBumiColors.textCardDark,
                                height: 1.2,
                                fontFamily: 'Poppins',
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              currencyFormatter.format(product.price),
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: WijiBumiColors.textCardDark,
                                height: 1.15,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Tombol '+'
                      InkWell(
                        onTap: isOutOfStock ? null : onQuickAdd,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: isOutOfStock
                                ? WijiBumiColors.textPlaceholder.withOpacity(0.5)
                                : WijiBumiColors.surfaceDark,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.22),
                              width: 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              isOutOfStock
                                  ? Icons.remove_shopping_cart_rounded
                                  : Icons.add_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlantImage(String url) {
    if (url.startsWith('http')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallbackPlant(),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            color: Colors.white.withOpacity(0.08),
            child: const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          );
        },
      );
    } else {
      return Image.asset(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallbackPlant(),
      );
    }
  }

  Widget _buildFallbackPlant() {
    return Container(
      decoration: BoxDecoration(
        color: WijiBumiColors.surfaceDark.withOpacity(0.6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Center(
        child: Icon(
          Icons.park_rounded,
          size: 36,
          color: WijiBumiColors.textMutedLight,
        ),
      ),
    );
  }
}
