import 'dart:ui';
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
                      child: Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: WijiBumiColors.lightMint,
                          child: const Center(
                            child: Icon(Icons.eco_rounded, size: 64, color: WijiBumiColors.freshLeaf),
                          ),
                        ),
                      ),
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
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: WijiBumiColors.textPrimary,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Harga & Satuan
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            currencyFormatter.format(product.price),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: WijiBumiColors.deepForest,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '/${product.unit}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: WijiBumiColors.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            isOutOfStock ? 'Stok Habis' : 'Stok: ${product.stock} ${product.unit}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isOutOfStock ? WijiBumiColors.error : WijiBumiColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Info Penjual & Jarak GPS
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: DynamicGlassDecoration.cleanCard(radius: 12),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: WijiBumiColors.lightMint,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.storefront_rounded,
                                color: WijiBumiColors.deepForest,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.sellerName,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: WijiBumiColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    product.sellerLocation,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: WijiBumiColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Obx(() {
                              final dist = locationController.distanceKm.value;
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: DynamicGlassDecoration.accentPill(
                                  radius: 10,
                                  fillColor: WijiBumiColors.lightMint,
                                  borderColor: WijiBumiColors.freshLeaf,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.location_on_rounded,
                                      size: 13,
                                      color: WijiBumiColors.deepForest,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      dist > 0 ? '${dist.toStringAsFixed(1)} km' : '2.5 km',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: WijiBumiColors.deepForest,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Deskripsi Produk
                      const Text(
                        'Deskripsi Produk',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: WijiBumiColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.description,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.6,
                          color: WijiBumiColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. Tombol Navigasi Mengambang Atas (Back)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: WijiBumiColors.softSage.withOpacity(0.7),
                        width: 1,
                      ),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                      color: WijiBumiColors.deepForest,
                      onPressed: () => Get.back(),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 3. Bar Kaca Bawah
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: DynamicGlassDecoration.glassBar(
                    radius: 20,
                    fullTopRadius: true,
                    fullBottomRadius: false,
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isOutOfStock)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Jumlah Pembelian:',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: WijiBumiColors.textPrimary,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: WijiBumiColors.lightMint.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: WijiBumiColors.softSage, width: 1),
                                ),
                                child: Row(
                                  children: [
                                    InkWell(
                                      onTap: _decrementQty,
                                      borderRadius: BorderRadius.circular(6),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Icon(Icons.remove, size: 16, color: WijiBumiColors.deepForest),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 14),
                                      child: Text(
                                        '$_quantity',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: WijiBumiColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: _incrementQty,
                                      borderRadius: BorderRadius.circular(6),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Icon(Icons.add, size: 16, color: WijiBumiColors.deepForest),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        if (!isOutOfStock) const SizedBox(height: 14),

                        Row(
                          children: [
                            Expanded(
                              child: CustomButton(
                                text: '+ Keranjang',
                                variant: ButtonVariant.secondaryGlass,
                                icon: Icons.shopping_cart_outlined,
                                height: 46,
                                onPressed: isOutOfStock
                                    ? null
                                    : () {
                                        cartController.addToCart(product, _quantity);
                                      },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CustomButton(
                                text: isOutOfStock ? 'Stok Habis' : 'Beli Sekarang',
                                height: 46,
                                onPressed: isOutOfStock
                                    ? null
                                    : () {
                                        cartController.addToCart(product, _quantity);
                                        Get.toNamed(AppRoutes.CHECKOUT);
                                      },
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
          ),
        ],
      ),
    );
  }
}
