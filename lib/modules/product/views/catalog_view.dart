import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/cart_badge.dart';
import '../../../widgets/category_card.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/error_state.dart';
import '../../../widgets/product_card.dart';
import '../controllers/product_controller.dart';
import '../../cart/controllers/cart_controller.dart';

class CatalogView extends StatelessWidget {
  const CatalogView({super.key});

  @override
  Widget build(BuildContext context) {
    final productController = Get.find<ProductController>();
    final cartController = Get.find<CartController>();
    final searchInputController = TextEditingController(text: productController.searchQuery.value);

    return Scaffold(
      backgroundColor: WijiBumiColors.backgroundCanvas,
      appBar: AppBar(
        title: const Text('Katalog Produk'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CartBadge(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Kaca Kontrol (Pencarian, Kategori, Filter & Sortir)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              border: Border(
                bottom: BorderSide(
                  color: WijiBumiColors.softSage.withOpacity(0.5),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Kolom Pencarian
                Container(
                  height: 44,
                  decoration: DynamicGlassDecoration.cleanCard(radius: 10),
                  child: TextField(
                    controller: searchInputController,
                    onChanged: (val) {
                      productController.onSearchChanged(val);
                    },
                    decoration: InputDecoration(
                      hintText: 'Cari nama produk...',
                      hintStyle: const TextStyle(fontSize: 13, color: WijiBumiColors.textMuted),
                      prefixIcon: const Icon(Icons.search_rounded, color: WijiBumiColors.deepForest, size: 20),
                      suffixIcon: Obx(
                        () => productController.searchQuery.value.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () {
                                  searchInputController.clear();
                                  productController.onSearchChanged('');
                                },
                              )
                            : const SizedBox.shrink(),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // 2. Bar Kategori Horizontal
                Obx(
                  () {
                    final selectedCategory = productController.selectedCategory.value;
                    final categories = productController.categories;

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: categories.map((cat) {
                          final isSelected = selectedCategory == cat.id;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
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
                  },
                ),
                const SizedBox(height: 10),

                // 3. Tombol Filter Kaca Ringkas: Urutkan Harga & Stok Tersedia
                Obx(
                  () {
                    final sortOrder = productController.priceSortOrder.value;
                    String sortLabel = 'Urutkan Harga';
                    if (sortOrder == PriceSortOrder.lowest) {
                      sortLabel = 'Harga: Termurah';
                    } else if (sortOrder == PriceSortOrder.highest) {
                      sortLabel = 'Harga: Termahal';
                    }

                    final inStockOnly = productController.filterInStockOnly.value;

                    return Row(
                      children: [
                        // Filter Sortir Harga
                        InkWell(
                          onTap: () => productController.toggleSortPrice(),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: DynamicGlassDecoration.accentPill(
                              radius: 8,
                              fillColor: sortOrder != PriceSortOrder.none
                                  ? WijiBumiColors.deepForest
                                  : WijiBumiColors.lightMint,
                              borderColor: WijiBumiColors.freshLeaf,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.swap_vert_rounded,
                                  size: 14,
                                  color: sortOrder != PriceSortOrder.none
                                      ? Colors.white
                                      : WijiBumiColors.deepForest,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  sortLabel,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: sortOrder != PriceSortOrder.none
                                        ? Colors.white
                                        : WijiBumiColors.deepForest,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Filter Stok Tersedia
                        InkWell(
                          onTap: () => productController.toggleFilterStock(),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: DynamicGlassDecoration.accentPill(
                              radius: 8,
                              fillColor: inStockOnly
                                  ? WijiBumiColors.deepForest
                                  : WijiBumiColors.lightMint,
                              borderColor: WijiBumiColors.freshLeaf,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  inStockOnly ? Icons.check_circle_rounded : Icons.inventory_2_outlined,
                                  size: 14,
                                  color: inStockOnly ? Colors.white : WijiBumiColors.deepForest,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Stok Tersedia Saja',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: inStockOnly ? Colors.white : WijiBumiColors.deepForest,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          // Area Tampilan Katalog: 4 Kondisi State (Loading, Data Tampil, Kosong, Error)
          Expanded(
            child: productController.obx(
              (products) {
                if (products == null || products.isEmpty) {
                  return EmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'Produk Tidak Ditemukan',
                    message: 'Tidak ada produk yang cocok dengan pencarian atau filter Anda.',
                    action: TextButton.icon(
                      icon: const Icon(Icons.refresh_rounded, color: WijiBumiColors.deepForest),
                      label: const Text('Reset Filter', style: TextStyle(color: WijiBumiColors.deepForest)),
                      onPressed: () {
                        searchInputController.clear();
                        productController.onSearchChanged('');
                        productController.selectCategory('semua');
                        if (productController.filterInStockOnly.value) {
                          productController.toggleFilterStock();
                        }
                        if (productController.priceSortOrder.value != PriceSortOrder.none) {
                          productController.toggleSortPrice();
                        }
                      },
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ProductCard(
                      product: product,
                      onQuickAdd: () {
                        cartController.addToCart(product, 1);
                      },
                    );
                  },
                );
              },
              onLoading: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(WijiBumiColors.freshLeaf),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Memuat produk segar...',
                      style: TextStyle(
                        fontSize: 12,
                        color: WijiBumiColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              onError: (error) => ErrorState(
                title: 'Gagal Memuat Produk',
                message: error ?? 'Tidak dapat terhubung ke server katalog.',
                onRetry: () => productController.loadProducts(showLoading: true),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
