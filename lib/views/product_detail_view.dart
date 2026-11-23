import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../app.dart';
import '../models/models.dart';
import '../controllers/shop_controller.dart';
import '../controllers/location_controller.dart';
import '../widgets/custom_button.dart';

class ProductDetailView extends StatefulWidget {
  const ProductDetailView({super.key});

  @override
  State<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView> {
  late ProductModel product;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    if (Get.arguments is ProductModel) {
      product = Get.arguments as ProductModel;
    } else {
      product = ProductModel(
        id: 'p1',
        name: 'Produk Pilihan Wiji Bumi',
        categoryId: 'sayuran',
        description: 'Produk segar berkualitas langsung dari petani.',
        price: 10000,
        unit: 'kg',
        stock: 10,
        imageUrl: 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=600',
        sellerName: 'Kebun Wiji Bumi',
        sellerLocation: 'Jakarta',
        sellerLat: -6.2088,
        sellerLng: 106.8456,
      );
    }
  }

  void _incrementQty() {
    if (_quantity < product.stock) {
      setState(() {
        _quantity++;
      });
    }
  }

  void _decrementQty() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<ShopController>();
    final locationController = Get.find<LocationController>();

    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final isOutOfStock = product.stock <= 0;

    return Scaffold(
      backgroundColor: WijiBumiColors.backgroundCanvas,
      body: Stack(
        children: [
          // 1. Konten Scrollable: Foto & Detail
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Foto Produk Penuh
                Stack(
                  children: [
                    SizedBox(
                      height: 340,
                      width: double.infinity,
                      child: _buildDetailImage(product.imageUrl),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 60,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              WijiBumiColors.backgroundCanvas,
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Panel Konten Detail
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge Kategori & Rating
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: DynamicGlassDecoration.accentPill(
                              radius: 8,
                              fillColor: WijiBumiColors.lightMint,
                              borderColor: WijiBumiColors.softSage,
                            ),
                            child: Text(
                              product.categoryId.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: WijiBumiColors.deepForest,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, size: 18, color: WijiBumiColors.starGold),
                              const SizedBox(width: 4),
                              Text(
                                '${product.rating.toStringAsFixed(1)} (Ulasan Pembeli)',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: WijiBumiColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Nama Produk
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: WijiBumiColors.textPrimary,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Harga & Stok
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '${currencyFormatter.format(product.price)} /${product.unit}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: WijiBumiColors.textPrimary,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isOutOfStock
                                  ? WijiBumiColors.error.withOpacity(0.12)
                                  : WijiBumiColors.lightMint,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isOutOfStock
                                    ? WijiBumiColors.error.withOpacity(0.4)
                                    : WijiBumiColors.softSage,
                                width: 1.0,
                              ),
                            ),
                            child: Text(
                              isOutOfStock ? 'Stok Habis' : 'Stok: ${product.stock} ${product.unit}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isOutOfStock
                                    ? WijiBumiColors.error
                                    : const Color(0xFFA7F3D0),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Kartu Deskripsi
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: DynamicGlassDecoration.glassCard(radius: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Deskripsi Produk',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: WijiBumiColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              product.description,
                              style: const TextStyle(
                                fontSize: 13,
                                color: WijiBumiColors.textSecondary,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Kartu Petani Mitra / Kebun
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: DynamicGlassDecoration.glassCard(radius: 16),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.12),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.24),
                                  width: 1.0,
                                ),
                              ),
                              child: const Icon(
                                Icons.eco_rounded,
                                color: Color(0xFFA7F3D0),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.sellerName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: WijiBumiColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Lokasi Kebun: ${product.sellerLocation}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: WijiBumiColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. Tombol Navigasi Mengambang (Kembali & Wishlist)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () => Get.back(),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: WijiBumiColors.deepForest,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.20),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.chevron_left_rounded,
                          size: 28,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Obx(() {
                      final isFav = cartController.isFavorite(product.id);
                      return InkWell(
                        onTap: () => cartController.toggleFavorite(product),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: WijiBumiColors.deepForest,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.20),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: isFav ? const Color(0xFFEF5350) : Colors.white,
                            size: 22,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),

          // 3. Panel Kuantitas & Tambah ke Keranjang
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: DynamicGlassDecoration.glassBar(radius: 20, fullBottomRadius: false),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    // Pengatur Kuantitas
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.24),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 16, color: Colors.white),
                            onPressed: isOutOfStock ? null : _decrementQty,
                          ),
                          Text(
                            '$_quantity',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, size: 16, color: Colors.white),
                            onPressed: isOutOfStock ? null : _incrementQty,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Tombol Tambah ke Keranjang
                    Expanded(
                      child: CustomButton(
                        text: isOutOfStock ? 'Stok Kosong' : '+ Keranjang',
                        icon: Icons.add_shopping_cart_rounded,
                        onPressed: isOutOfStock
                            ? null
                            : () {
                                cartController.addToCart(product, _quantity);
                                if (locationController.selectedAddress.value != null) {
                                  locationController.updateDistanceAndShipping(
                                    locationController.selectedAddress.value!,
                                    cartController.getTotalPrice(),
                                  );
                                }
                              },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailImage(String url) {
    final cleanUrl = url.trim();
    final fallback = Container(
      color: WijiBumiColors.lightMint,
      child: const Center(
        child: Icon(Icons.eco_rounded, size: 80, color: WijiBumiColors.freshLeaf),
      ),
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
