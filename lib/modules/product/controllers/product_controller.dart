import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/product_repository.dart';

enum PriceSortOrder { none, lowest, highest }

class ProductController extends GetxController with StateMixin<List<ProductModel>> {
  final ProductRepository productRepository;

  ProductController({required this.productRepository});

  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxList<ProductModel> rawProducts = <ProductModel>[].obs;

  final RxString selectedCategory = 'semua'.obs;
  final RxString searchQuery = ''.obs;
  final Rx<PriceSortOrder> priceSortOrder = PriceSortOrder.none.obs;
  final RxBool filterInStockOnly = false.obs;

  final TextEditingController searchInputController = TextEditingController();

  bool get hasActiveFilter =>
      priceSortOrder.value != PriceSortOrder.none ||
      filterInStockOnly.value ||
      searchQuery.value.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
    loadProducts();
  }

  Future<void> loadCategories() async {
    try {
      final list = await productRepository.getCategories();
      categories.assignAll([
        CategoryModel(id: 'semua', name: 'All', icon: 'eco'),
        ...list,
      ]);
    } catch (_) {}
  }

  Future<void> loadProducts({bool showLoading = true}) async {
    if (showLoading) {
      change(null, status: RxStatus.loading());
    }

    try {
      final list = await productRepository.getProducts(
        category: selectedCategory.value == 'semua' ? null : selectedCategory.value,
        q: searchQuery.value,
      );
      rawProducts.assignAll(list);
      _applyFiltersAndNotify();
    } catch (e) {
      change(
        null,
        status: RxStatus.error(
          e.toString().replaceAll('Exception: ', '').replaceAll('SocketException: ', ''),
        ),
      );
    }
  }

  void _applyFiltersAndNotify() {
    List<ProductModel> filtered = List<ProductModel>.from(rawProducts);

    // Filter Kategori
    if (selectedCategory.value != 'semua') {
      filtered = filtered
          .where((p) => p.categoryId.toLowerCase() == selectedCategory.value.toLowerCase())
          .toList();
    }

    // Filter Pencarian
    if (searchQuery.value.trim().isNotEmpty) {
      final q = searchQuery.value.toLowerCase().trim();
      filtered = filtered
          .where((p) => p.name.toLowerCase().contains(q) || p.description.toLowerCase().contains(q))
          .toList();
    }

    // Filter Stok Tersedia
    if (filterInStockOnly.value) {
      filtered = filtered.where((p) => p.stock > 0).toList();
    }

    // Sortir Harga
    if (priceSortOrder.value == PriceSortOrder.lowest) {
      filtered.sort((a, b) => a.price.compareTo(b.price));
    } else if (priceSortOrder.value == PriceSortOrder.highest) {
      filtered.sort((a, b) => b.price.compareTo(a.price));
    }

    if (filtered.isEmpty) {
      change([], status: RxStatus.empty());
    } else {
      change(filtered, status: RxStatus.success());
    }
  }

  void selectCategory(String categoryId) {
    selectedCategory.value = categoryId;
    _applyFiltersAndNotify();
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    if (searchInputController.text != query) {
      searchInputController.text = query;
      searchInputController.selection = TextSelection.collapsed(offset: query.length);
    }
    _applyFiltersAndNotify();
  }

  void clearSearch() {
    searchQuery.value = '';
    searchInputController.clear();
    _applyFiltersAndNotify();
  }

  void setSortPrice(PriceSortOrder order) {
    priceSortOrder.value = order;
    _applyFiltersAndNotify();
  }

  void toggleSortPrice() {
    if (priceSortOrder.value == PriceSortOrder.none) {
      priceSortOrder.value = PriceSortOrder.lowest;
    } else if (priceSortOrder.value == PriceSortOrder.lowest) {
      priceSortOrder.value = PriceSortOrder.highest;
    } else {
      priceSortOrder.value = PriceSortOrder.none;
    }
    _applyFiltersAndNotify();
  }

  void toggleFilterStock() {
    filterInStockOnly.value = !filterInStockOnly.value;
    _applyFiltersAndNotify();
  }

  void setFilterStock(bool inStock) {
    filterInStockOnly.value = inStock;
    _applyFiltersAndNotify();
  }

  void resetAllFilters() {
    searchQuery.value = '';
    searchInputController.clear();
    selectedCategory.value = 'semua';
    priceSortOrder.value = PriceSortOrder.none;
    filterInStockOnly.value = false;
    _applyFiltersAndNotify();
  }

  @override
  void onClose() {
    searchInputController.dispose();
    super.onClose();
  }
}
