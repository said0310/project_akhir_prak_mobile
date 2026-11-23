import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app.dart';
import '../controllers/auth_controller.dart';
import '../controllers/shop_controller.dart';
import '../controllers/notification_controller.dart';
import '../widgets/product_card.dart';
import '../widgets/category_card.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final productController = Get.find<ShopController>();
    final cartController = productController;
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: WijiBumiColors.backgroundCanvas,
      body: Stack(
        children: [
          // 1. Latar Belakang Gradasi Hijau Botani yang Kaya & Cahaya Ambient
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF1C2B1E),
                    Color(0xFF243827),
                    Color(0xFF1C2B1E),
                  ],
                  stops: [0.0, 0.50, 1.0],
                ),
              ),
            ),
          ),

          // Glowing Emerald Orb Kanan Atas
          Positioned(
            top: -40,
            right: -30,
            child: IgnorePointer(
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF4CAF50).withOpacity(0.35),
                      const Color(0xFF2E7D32).withOpacity(0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Glowing Mint Orb Kiri Tengah
          Positioned(
            top: 90,
            left: -40,
            child: IgnorePointer(
              child: Container(
                width: 190,
                height: 190,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF81C784).withOpacity(0.30),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 2. Konten Halaman Scrollable
          SafeArea(
            bottom: false,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),

                      // Header Bar: Sapaan User & Tombol Notifikasi Liquid Glass
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Hello!',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFFD8E8DC),
                                      height: 1.3,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Obx(() {
                                    final name =
                                        authController.currentUser.value?.name ??
                                            'Nuril Anggara';
                                    return Text(
                                      name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 19,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        height: 1.3,
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Tombol Notifikasi Liquid Glass 48 x 48 px dengan Specular Border
                            Obx(() {
                              final notifCtrl = Get.isRegistered<NotificationController>()
                                  ? Get.find<NotificationController>()
                                  : Get.put(NotificationController());
                              final unreadCount = notifCtrl.unreadCount;

                              return Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  GestureDetector(
                                    onTap: () => Get.toNamed(AppRoutes.REMINDERS),
                                    behavior: HitTestBehavior.opaque,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                                        child: Container(
                                          width: 48,
                                          height: 48,
                                          decoration: DynamicGlassDecoration.liquidGlassDark(radius: 14),
                                          child: const Center(
                                            child: Icon(
                                              Icons.notifications_rounded,
                                              size: 22,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (unreadCount > 0)
                                    Positioned(
                                      top: -4,
                                      right: -4,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                        constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                                        decoration: BoxDecoration(
                                          color: WijiBumiColors.error,
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                            color: const Color(0xFF1C2B1E),
                                            width: 2.0,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.25),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Text(
                                            unreadCount > 99 ? '99+' : '$unreadCount',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                              height: 1.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 2. Search & Filter Row dengan Liquid Glass
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Row(
                          children: [
                            // Search Input Bar Liquid Glass
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                                  child: Container(
                                    height: 52,
                                    padding: const EdgeInsets.symmetric(horizontal: 14),
                                    decoration: DynamicGlassDecoration.liquidGlassDark(radius: 16),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.search_rounded,
                                          size: 22,
                                          color: Color(0xFFD8E8DC),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: TextField(
                                            controller:
                                                productController.searchInputController,
                                            onChanged:
                                                productController.onSearchChanged,
                                            cursorColor: Colors.white,
                                            style: const TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 14,
                                              color: Colors.white,
                                            ),
                                            decoration: const InputDecoration(
                                              isDense: true,
                                              hintText: 'Cari sayuran, buah, atau tanaman...',
                                              hintStyle: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 13,
                                                fontWeight: FontWeight.w400,
                                                color: Color(0xFFD8E8DC),
                                              ),
                                              border: InputBorder.none,
                                              contentPadding: EdgeInsets.zero,
                                            ),
                                          ),
                                        ),
                                        Obx(() {
                                          if (productController
                                              .searchQuery.value.isNotEmpty) {
                                            return GestureDetector(
                                              onTap: productController.clearSearch,
                                              behavior: HitTestBehavior.opaque,
                                              child: const Padding(
                                                padding: EdgeInsets.all(6.0),
                                                child: Icon(
                                                  Icons.clear_rounded,
                                                  size: 18,
                                                  color: Color(0xFFD8E8DC),
                                                ),
                                              ),
                                            );
                                          }
                                          return const SizedBox.shrink();
                                        }),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Tombol Toggle Filter Liquid Glass (52 x 52 px)
                            GestureDetector(
                              onTap: () => _showFilterBottomSheet(
                                  context, productController),
                              behavior: HitTestBehavior.opaque,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                                  child: Container(
                                    width: 52,
                                    height: 52,
                                    decoration: DynamicGlassDecoration.liquidGlassDark(radius: 16),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Obx(() {
                                          final isFiltered =
                                              productController.hasActiveFilter;
                                          return Icon(
                                            Icons.tune_rounded,
                                            size: 22,
                                            color: isFiltered
                                                ? const Color(0xFF81C784)
                                                : Colors.white,
                                          );
                                        }),
                                        Obx(() {
                                          if (!productController.hasActiveFilter) {
                                            return const SizedBox.shrink();
                                          }
                                          return Positioned(
                                            top: 11,
                                            right: 11,
                                            child: Container(
                                              width: 8,
                                              height: 8,
                                              decoration: const BoxDecoration(
                                                color: Color(0xFF81C784),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                  // Category Tabs (All, Buah, Sayuran, Bunga, Beras & Umbi, Rempah)
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Obx(() {
                      final categories = productController.categories;
                      final selectedCategory =
                          productController.selectedCategory.value;
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: categories.map((cat) {
                            final isSelected =
                                selectedCategory.toLowerCase() ==
                                    cat.id.toLowerCase();
                            return Padding(
                              padding: const EdgeInsets.only(right: 18.0),
                              child: CategoryCard(
                                key: ValueKey('tab_${cat.id}'),
                                category: cat,
                                isSelected: isSelected,
                                onTap: () {
                                  productController.selectCategory(cat.id);
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    }),
                  ),

                  // Active Filter Pills
                  Obx(() {
                    final hasFilter = productController.hasActiveFilter;
                    if (!hasFilter) return const SizedBox.shrink();
                    final selectedCategoryId =
                        productController.selectedCategory.value;
                    final selectedCategoryName = productController.categories
                            .firstWhereOrNull(
                              (category) =>
                                  category.id == selectedCategoryId,
                            )
                            ?.name ??
                        selectedCategoryId;

                    return Padding(
                      padding: const EdgeInsets.only(
                          left: 24.0, right: 24.0, top: 12.0),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: [
                            if (selectedCategoryId != 'semua')
                              _buildActiveFilterChip(
                                label: 'Kategori: ${_categoryFilterLabel(
                                  selectedCategoryId,
                                  selectedCategoryName,
                                )}',
                                onRemove: () =>
                                    productController.selectCategory('semua'),
                              ),
                            if (productController.searchQuery.value.isNotEmpty)
                              _buildActiveFilterChip(
                                label:
                                    'Cari: "${productController.searchQuery.value}"',
                                onRemove: productController.clearSearch,
                              ),
                            if (productController.priceSortOrder.value !=
                                PriceSortOrder.none)
                              _buildActiveFilterChip(
                                label: productController.priceSortOrder.value ==
                                        PriceSortOrder.lowest
                                    ? 'Harga: Termurah'
                                    : 'Harga: Termahal',
                                onRemove: () => productController
                                    .setSortPrice(PriceSortOrder.none),
                              ),
                            if (productController.filterInStockOnly.value)
                              _buildActiveFilterChip(
                                label: 'Ready Stock',
                                onRemove: () =>
                                    productController.setFilterStock(false),
                              ),
                            GestureDetector(
                              onTap: productController.resetAllFilters,
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                child: Text(
                                  'Reset',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: WijiBumiColors.textSecondary,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 24),

                  // 3. Section Produk Unggulan & Horizontal Carousel
                  productController.obx(
                    (products) {
                      if (products == null || products.isEmpty) {
                        return _buildEmptySearchState(productController);
                      }

                      return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Section Unggulan
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24.0),
                              child: Obx(() {
                                final selected =
                                    productController.selectedCategory.value;
                                String title = 'Pilihan Unggulan';
                                if (selected != 'semua') {
                                  final cat = productController.categories
                                      .firstWhereOrNull((c) => c.id == selected);
                                  if (cat != null) {
                                    title =
                                        '${_categoryFilterLabel(cat.id, cat.name)} Pilihan';
                                  }
                                }
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800,
                                          color: WijiBumiColors.textPrimary,
                                          height: 1.15,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            ),

                            const SizedBox(height: 12),

                            // Carousel Horizontal Glass Card (Scroll ke Samping)
                            SizedBox(
                              height: 226,
                              child: ListView.separated(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 6),
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                itemCount: products.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 14),
                                itemBuilder: (context, index) {
                                  final product = products[index];
                                  return ProductCard(
                                    key: ValueKey('top_${product.id}'),
                                    product: product,
                                    heroTagPrefix: 'top',
                                    width: 156,
                                    height: 206,
                                    onQuickAdd: () =>
                                        cartController.addToCart(product, 1),
                                  );
                                },
                              ),
                            ),

                            const SizedBox(height: 28),

                            // 4. Section "Promotion"
                            _buildPromotionBanner(),

                            const SizedBox(height: 28),

                            // 5. Section "Katalog Lengkap" (2 Kolom Kanan & Kiri, Scroll ke Bawah)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Katalog Lengkap',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 22,
                                            fontWeight: FontWeight.w800,
                                            color: WijiBumiColors.textPrimary,
                                            height: 1.15,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Koleksi segar siap panen & tanaman asri',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            color: WijiBumiColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: DynamicGlassDecoration.accentPill(
                                      radius: 8,
                                      fillColor: WijiBumiColors.lightMint,
                                      borderColor: WijiBumiColors.softSage,
                                    ),
                                    child: Text(
                                      '${products.length} Produk',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: WijiBumiColors.deepForest,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          const SizedBox(height: 16),

                          // Grid 2 Kolom (Kanan & Kiri)
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.70,
                            ),
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final product = products[index];
                              return ProductCard(
                                key: ValueKey('grid_${product.id}'),
                                product: product,
                                heroTagPrefix: 'grid',
                                onQuickAdd: () =>
                                    cartController.addToCart(product, 1),
                              );
                            },
                          ),
                        ],
                      );
                    },
                    onEmpty: _buildEmptySearchState(productController),
                    onLoading: const SizedBox(
                      height: 240,
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              WijiBumiColors.deepForest),
                        ),
                      ),
                    ),
                    onError: (err) => Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        err ?? 'Gagal memuat produk',
                        style: const TextStyle(
                            color: WijiBumiColors.textSecondary),
                      ),
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  ),
);
}

  Widget _buildActiveFilterChip(
      {required String label, required VoidCallback onRemove}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: WijiBumiColors.borderSage, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1C2B1E).withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: WijiBumiColors.textPrimary,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close_rounded,
              size: 14,
              color: WijiBumiColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromotionBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Promotion',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: WijiBumiColors.textPrimary,
              height: 1.15,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: const Text(
              'Get special discount up to 20% on selected organic harvest and plants today!',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: WijiBumiColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Kartu Promosi Glassmorphism Luminous
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: DynamicGlassDecoration.glassCard(radius: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF142117),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.25),
                                width: 1.0,
                              ),
                            ),
                            child: const Text(
                              'OFFER OF THE WEEK',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Free Pot & Fertilizer',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          const Text(
                            'For all big plants orders above Rp 150.000',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFC8DDD0),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFA7F3D0),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFA7F3D0).withOpacity(0.30),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                          color: Color(0xFF142117),
                        ),
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

  static Widget _buildEmptySearchState(ShopController productController) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 44,
            color: WijiBumiColors.textSecondary,
          ),
          const SizedBox(height: 10),
          const Text(
            'Tanaman tidak ditemukan',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: WijiBumiColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Coba kata kunci lain atau reset filter',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: WijiBumiColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: productController.resetAllFilters,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: WijiBumiColors.surfaceDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Reset Filter',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context, ShopController controller) {
    Get.bottomSheet(
      ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: WijiBumiColors.borderSage,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter & Urutkan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: WijiBumiColors.textPrimary,
                        ),
                      ),
                      GestureDetector(
                        onTap: controller.resetAllFilters,
                        child: const Text(
                          'Reset',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: WijiBumiColors.freshLeaf,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Kategori Produk',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: WijiBumiColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Obx(() {
                    final selectedCategory =
                        controller.selectedCategory.value;
                    final categories = controller.categories
                        .where((category) => category.id != 'semua')
                        .toList();
                    const categoryOrder = {
                      'Bunga': 0,
                      'Buah': 1,
                      'Sayuran': 2,
                      'Beras & Umbi': 3,
                      'Rempah': 4,
                    };
                    categories.sort((first, second) {
                      final firstOrder = categoryOrder[
                              _categoryFilterLabel(first.id, first.name)] ??
                          5;
                      final secondOrder = categoryOrder[
                              _categoryFilterLabel(second.id, second.name)] ??
                          5;
                      return firstOrder.compareTo(secondOrder);
                    });

                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (var index = 0;
                            index < categories.length;
                            index++)
                          _buildFilterOption(
                            label: _categoryFilterLabel(
                              categories[index].id,
                              categories[index].name,
                            ),
                            isSelected:
                                selectedCategory == categories[index].id,
                            onTap: () => controller.selectCategory(
                              categories[index].id,
                            ),
                          ),
                      ],
                    );
                  }),
                  const SizedBox(height: 20),
                  const Text(
                    'Ketersediaan Produk',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: WijiBumiColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Obx(() {
                    final inStock = controller.filterInStockOnly.value;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: DynamicGlassDecoration.glassCard(radius: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Hanya Stok Tersedia (Ready)',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: WijiBumiColors.textPrimary,
                            ),
                          ),
                          Switch(
                            value: inStock,
                            activeColor: WijiBumiColors.freshLeaf,
                            onChanged: (val) => controller.setFilterStock(val),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA7F3D0),
                        foregroundColor: const Color(0xFF142117),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Terapkan Filter',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF142117),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildFilterOption({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFA7F3D0)
              : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFA7F3D0)
                : Colors.white.withOpacity(0.20),
            width: 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? const Color(0xFF142117) : const Color(0xFFC8DDD0),
          ),
        ),
      ),
    );
  }

  String _categoryFilterLabel(String id, String fallback) {
    switch (id.toLowerCase()) {
      case 'tanaman_hias':
      case 'bunga':
        return 'Bunga';
      case 'buah':
        return 'Buah';
      case 'sayur':
      case 'sayuran':
        return 'Sayuran';
      case 'beras&umbi-umbian':
        return 'Beras & Umbi';
      case 'rempah-rempah':
        return 'Rempah';
      default:
        return fallback;
    }
  }
}
