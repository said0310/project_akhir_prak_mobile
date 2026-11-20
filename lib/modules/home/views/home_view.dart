import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/product_card.dart';
import '../../../widgets/category_card.dart';
import '../../product/controllers/product_controller.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../app/routes/app_routes.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final productController = Get.find<ProductController>();
    final cartController = Get.find<CartController>();
    final authController = Get.find<AuthController>();
    final searchInputController = TextEditingController(text: productController.searchQuery.value);

    return Scaffold(
      backgroundColor: WijiBumiColors.bgPrimary,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          clipBehavior: Clip.none,
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),

                  // 1. Header Bar (Spec Section 5 Item 1):
                  // Flex horizontal space-between.
                  // Kiri: Teks bertumpuk "Hello!" (#C6D6C7) dan Nama User (#FFFFFF, gap 4px).
                  // Kanan: Tombol notifikasi 48 x 48 px, radius 14 px, fill #344E37, lonceng putih solid 22 px.
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Hello!',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: WijiBumiColors.textMutedLight,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Obx(() {
                              final name = authController.currentUser.value?.name ?? 'Nuril Anggara';
                              return Text(
                                name,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 19,
                                  fontWeight: FontWeight.w600,
                                  color: WijiBumiColors.textWhite,
                                  height: 1.3,
                                ),
                              );
                            }),
                          ],
                        ),

                        // Tombol Notifikasi 48 x 48 px, radius 14 px, fill #18261A, border kaca, lonceng putih 22 px
                        GestureDetector(
                          onTap: () {
                            Get.toNamed(AppRoutes.REMINDERS);
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: WijiBumiColors.surfaceDark,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.16),
                                width: 1.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.20),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.notifications_rounded,
                                size: 22,
                                color: WijiBumiColors.textWhite,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 26),

                  // 2. Search & Filter Row (Spec Section 5 Item 2):
                  // Jarak dari header 24-28 px, gap 14 px.
                  // Search bar flex: 1, tinggi 52 px, radius 16 px, fill #344E37, padding kiri 20 px.
                  // Tombol kanan 52 x 52 px, radius 16 px, fill #344E37, ikon chevron kanan > #9FB5A1.
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 52,
                            padding: const EdgeInsets.only(left: 16, right: 8),
                            decoration: BoxDecoration(
                              color: WijiBumiColors.surfaceDark,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.12),
                                width: 1.0,
                              ),
                            ),
                            child: Center(
                              child: TextField(
                                controller: searchInputController,
                                onChanged: (val) {
                                  productController.onSearchChanged(val);
                                },
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  color: WijiBumiColors.textWhite,
                                ),
                                decoration: InputDecoration(
                                  isDense: true,
                                  hintText: 'search...',
                                  hintStyle: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: WijiBumiColors.textPlaceholder,
                                  ),
                                  icon: const Icon(
                                    Icons.search_rounded,
                                    size: 22,
                                    color: WijiBumiColors.textPlaceholder,
                                  ),
                                  border: InputBorder.none,
                                  suffixIcon: Obx(
                                    () => productController.searchQuery.value.isNotEmpty
                                        ? IconButton(
                                            icon: const Icon(
                                              Icons.clear_rounded,
                                              size: 18,
                                              color: WijiBumiColors.textPlaceholder,
                                            ),
                                            onPressed: () {
                                              searchInputController.clear();
                                              productController.onSearchChanged('');
                                            },
                                          )
                                        : const SizedBox.shrink(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Tombol Kanan 52 x 52 px, radius 16 px, fill #18261A, border kaca, ikon chevron >
                        GestureDetector(
                          onTap: () {
                            productController.toggleSortPrice();
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: WijiBumiColors.surfaceDark,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.12),
                                width: 1.0,
                              ),
                            ),
                            child: Center(
                              child: Obx(() {
                                final isSorting = productController.priceSortOrder.value != PriceSortOrder.none;
                                return Icon(
                                  isSorting ? Icons.swap_vert_rounded : Icons.chevron_right_rounded,
                                  size: 24,
                                  color: isSorting ? WijiBumiColors.textWhite : WijiBumiColors.textPlaceholder,
                                );
                              }),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // 3. Category Tabs (Spec Section 5 Item 3):
                  // Jarak dari search row 20 px, distribusi merata (All, Big plants, Outdoor, Indoor).
                  // Indikator tab aktif: garis putih horizontal lebar 18 px, tinggi 2.5 px, radius 2 px, 6 px di bawah label.
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Obx(() {
                      final selectedCategory = productController.selectedCategory.value;
                      final categories = productController.categories;

                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: categories.map((cat) {
                            final isSelected = selectedCategory == cat.id;
                            return Padding(
                              padding: const EdgeInsets.only(right: 18.0),
                              child: CategoryCard(
                                key: ValueKey(cat.id),
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

                  const SizedBox(height: 26),

                  // 4. Section "All Plants" (Spec Section 5 Item 4):
                  // Heading: ExtraBold (800-900), 24-26 px, #FFFFFF.
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Obx(() {
                      final selected = productController.selectedCategory.value;
                      String title = 'All Plants';
                      if (selected != 'semua') {
                        final cat = productController.categories.firstWhereOrNull((c) => c.id == selected);
                        if (cat != null) {
                          title = cat.name;
                        }
                      }
                      return Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                          color: WijiBumiColors.textWhite,
                          height: 1.15,
                          letterSpacing: -0.5,
                        ),
                      );
                    }),
                  ),

                  // Carousel Horizontal Glass Card dengan Efek 3D Pop-Out (Spec Section 4 & 5 Item 4):
                  // Padding-top 30 px agar daun menembus batas atas tanpa terpotong.
                  // Gap 20 px antar kartu, padding kiri 24 px, kartu kedua terlihat sebagian (peek).
                  productController.obx(
                    (products) {
                      if (products == null || products.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              const Icon(
                                Icons.search_off_rounded,
                                size: 48,
                                color: WijiBumiColors.textPlaceholder,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'No plants found',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: WijiBumiColors.textWhite,
                                ),
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () {
                                  searchInputController.clear();
                                  productController.onSearchChanged('');
                                  productController.selectCategory('semua');
                                },
                                child: const Text(
                                  'Reset Filter',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: WijiBumiColors.textWhite,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return SizedBox(
                        height: 295,
                        child: ListView.separated(
                          padding: const EdgeInsets.only(
                            left: 24,
                            right: 24,
                            top: 10,
                            bottom: 15,
                          ),
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: products.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 18),
                          itemBuilder: (context, index) {
                            final product = products[index];
                            return ProductCard(
                              key: ValueKey(product.id),
                              product: product,
                              width: 208,
                              height: 270,
                              onQuickAdd: () {
                                cartController.addToCart(product, 1);
                              },
                            );
                          },
                        ),
                      );
                    },
                    onLoading: const SizedBox(
                      height: 280,
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(WijiBumiColors.textWhite),
                        ),
                      ),
                    ),
                    onError: (err) => Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        err ?? 'Failed to load plants',
                        style: const TextStyle(color: WijiBumiColors.textMutedLight),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 5. Section "Promotion" (Spec Section 5 Item 5):
                  // Jarak dari carousel 32 px. Judul display putih diikuti subteks max width 85%.
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Promotion',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 25,
                            fontWeight: FontWeight.w900,
                            color: WijiBumiColors.textWhite,
                            height: 1.15,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 320),
                          child: const Text(
                            'Get special discount up to 20% on selected organic harvest and plants today!',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: WijiBumiColors.textMutedLight,
                              height: 1.45,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Kartu Promosi Glassmorphism Luminous
                        ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: DynamicGlassDecoration.glassCard(radius: 28),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: WijiBumiColors.surfaceDark,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: Colors.white.withOpacity(0.16),
                                              width: 1.0,
                                            ),
                                          ),
                                          child: const Text(
                                            'OFFER OF THE WEEK',
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: WijiBumiColors.textWhite,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        const Text(
                                          'Free Pot & Fertilizer',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 18,
                                            fontWeight: FontWeight.w800,
                                            color: WijiBumiColors.textCardDark,
                                            height: 1.2,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        const Text(
                                          'For all big plants orders above Rp 150.000',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF1A3320),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: WijiBumiColors.surfaceDark,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.18),
                                        width: 1.0,
                                      ),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 20,
                                        color: WijiBumiColors.textWhite,
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
                  ),

                  // Bottom padding for fixed bottom navigation bar (80 px height)
                  const SizedBox(height: 110),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
