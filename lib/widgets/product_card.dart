import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../app.dart';
import '../models/models.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onQuickAdd;
  final double? width;
  final double? height;
  final String? heroTagPrefix;

  const ProductCard({
    super.key,
    required this.product,
    this.onQuickAdd,
    this.width,
    this.height,
    this.heroTagPrefix,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final isOutOfStock = product.stock <= 0;

    return GestureDetector(
      onTap: () {
        Get.toNamed(
          '${AppRoutes.PRODUCT}/${product.id}',
          arguments: product,
        );
      },
      child: Container(
        width: width,
        height: height,
        decoration: DynamicGlassDecoration.glassCard(radius: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
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
                          borderRadius: BorderRadius.circular(12),
                          child: Hero(
                            tag: '${heroTagPrefix ?? 'product'}_img_${product.id}',
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
                                color: WijiBumiColors.textPrimary,
                                height: 1.2,
                                fontFamily: 'Poppins',
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              currencyFormatter.format(product.price),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: WijiBumiColors.textPrimary,
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
                                ? Colors.white.withOpacity(0.10)
                                : const Color(0xFF142117),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.25),
                              width: 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.20),
                                blurRadius: 4,
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
                              color: isOutOfStock
                                  ? const Color(0xFF9EB5A4)
                                  : Colors.white,
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
    final cleanUrl = url.trim();
    if (cleanUrl.isEmpty) {
      return _buildFallbackPlant();
    }
    if (cleanUrl.startsWith('http://') || cleanUrl.startsWith('https://')) {
      return Image.network(
        cleanUrl,
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
      final assetPath = cleanUrl.startsWith('assets/')
          ? cleanUrl
          : 'assets/images/products/$cleanUrl';
      return Image.asset(
        assetPath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallbackPlant(),
      );
    }
  }

  Widget _buildFallbackPlant() {
    return Container(
      decoration: BoxDecoration(
        color: WijiBumiColors.lightMint,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Icon(
          Icons.eco_rounded,
          size: 32,
          color: WijiBumiColors.freshLeaf,
        ),
      ),
    );
  }
}
