import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../services/database_helper.dart';
import '../widgets/glass_feedback.dart';
import 'auth_controller.dart';
import 'notification_controller.dart';

enum PriceSortOrder { none, lowest, highest }

/// ShopController
/// Menggabungkan manajemen:
/// 1. Katalog & Filter Produk
/// 2. Keranjang Belanja (SQLite)
/// 3. Wishlist / Favorit (SQLite)
/// 4. Checkout & Pesanan (API)
class ShopController extends GetxController with StateMixin<List<ProductModel>> {
  final ApiService apiService;

  ShopController({ApiService? apiService, ProductRepository? productRepository})
      : apiService = apiService ?? productRepository?.apiService ?? ApiService();

  String get _currentUserId {
    if (Get.isRegistered<AuthController>()) {
      return Get.find<AuthController>().currentUser.value?.id ?? 'guest';
    }
    return 'guest';
  }

  // ===========================================================================
  // 1. STATE & LOGIKA PRODUK
  // ===========================================================================
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxList<ProductModel> rawProducts = <ProductModel>[].obs;

  final RxString selectedCategory = 'semua'.obs;
  final RxString searchQuery = ''.obs;
  final Rx<PriceSortOrder> priceSortOrder = PriceSortOrder.none.obs;
  final RxBool filterInStockOnly = false.obs;

  final TextEditingController searchInputController = TextEditingController();

  bool get hasActiveFilter =>
      selectedCategory.value != 'semua' ||
      priceSortOrder.value != PriceSortOrder.none ||
      filterInStockOnly.value ||
      searchQuery.value.isNotEmpty;

  // ===========================================================================
  // 2. STATE KERANJANG BELANJA (CART)
  // ===========================================================================
  final RxList<CartItemModel> items = <CartItemModel>[].obs;

  int get totalItemCount {
    return items.fold<int>(0, (sum, item) => sum + item.quantity);
  }

  double getTotalPrice() {
    return items
        .where((item) => item.isSelected)
        .fold<double>(0.0, (sum, item) => sum + item.subtotal);
  }

  // ===========================================================================
  // 3. STATE WISHLIST / FAVORIT
  // ===========================================================================
  final RxList<ProductModel> wishlistItems = <ProductModel>[].obs;

  // ===========================================================================
  // 4. STATE PESANAN & CHECKOUT
  // ===========================================================================
  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final RxBool isLoadingOrders = false.obs;
  RxBool get isLoading => isLoadingOrders;
  final RxBool isSubmitting = false.obs;
  final RxString selectedPaymentMethod = 'Transfer Bank'.obs;
  final Rx<OrderModel?> currentOrder = Rx<OrderModel?>(null);

  final List<String> availablePaymentMethods = [
    'Transfer Bank',
    'E-Wallet (GoPay/OVO/ShopeePay)',
    'COD (Bayar di Tempat)',
  ];

  @override
  void onInit() {
    super.onInit();
    loadCategories();
    loadProducts();
    loadFromDatabase();
    loadWishlist();
    loadOrders();
  }

  @override
  void onClose() {
    searchInputController.dispose();
    super.onClose();
  }

  // ---------------------------------------------------------------------------
  // PRODUK: Operasi & Filter
  // ---------------------------------------------------------------------------
  Future<void> loadCatalogFromCsv() async {
    await ApiService.loadCatalogFromCsv();
    await loadCategories();
    await loadProducts();
  }

  Future<void> loadCategories() async {
    try {
      final list = await apiService.getCategories();
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
      final list = await apiService.getProducts();
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
      final sel = selectedCategory.value.toLowerCase().trim();
      filtered = filtered.where((p) {
        final catP = p.categoryId.toLowerCase().trim();
        if (catP == sel) return true;
        if ((catP == 'sayur' || catP == 'sayuran') && (sel == 'sayur' || sel == 'sayuran')) return true;
        if ((catP == 'bunga' || catP == 'tanaman_hias') && (sel == 'bunga' || sel == 'tanaman_hias')) return true;
        return false;
      }).toList();
    }

    // Filter Pencarian
    if (searchQuery.value.trim().isNotEmpty) {
      final q = searchQuery.value.toLowerCase().trim();
      filtered = filtered
          .where((p) =>
              p.name.toLowerCase().contains(q) ||
              p.description.toLowerCase().contains(q) ||
              p.origin.toLowerCase().contains(q))
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

  // ---------------------------------------------------------------------------
  // KERANJANG (CART): Operasi SQLite
  // ---------------------------------------------------------------------------
  Future<void> loadFromDatabase() async {
    try {
      final userItems = await DatabaseHelper.getCartItems(_currentUserId);
      items.assignAll(userItems);
    } catch (_) {}
  }

  Future<void> addToCart(ProductModel product, [int quantity = 1]) async {
    if (product.stock <= 0) {
      GlassFeedback.showSnackbar(
        title: 'Stok Habis',
        message: 'Produk ini sedang tidak tersedia.',
        isError: true,
      );
      return;
    }

    final existingIndex = items.indexWhere((i) => i.productId == product.id);

    if (existingIndex != -1) {
      final existingItem = items[existingIndex];
      final newQuantity = existingItem.quantity + quantity;

      if (newQuantity > product.stock) {
        GlassFeedback.showSnackbar(
          title: 'Batas Stok Terlampaui',
          message: 'Stok tersedia hanya ${product.stock} ${product.unit}',
          isError: true,
        );
        return;
      }

      existingItem.quantity = newQuantity;
      existingItem.isSelected = true;
      items[existingIndex] = existingItem;
      await DatabaseHelper.saveCartItem(existingItem);
    } else {
      final finalQty = quantity > product.stock ? product.stock : quantity;
      final newItem = CartItemModel(
        productId: product.id,
        name: product.name,
        price: product.price,
        unit: product.unit,
        imageUrl: product.imageUrl,
        stock: product.stock,
        quantity: finalQty,
        isSelected: true,
        userId: _currentUserId,
      );

      items.add(newItem);
      await DatabaseHelper.saveCartItem(newItem);
    }

    GlassFeedback.showSnackbar(
      title: 'Masuk Keranjang',
      message: '${product.name} berhasil ditambahkan ($quantity ${product.unit}).',
    );
  }

  Future<void> updateQuantity(String productId, int newQuantity) async {
    final index = items.indexWhere((i) => i.productId == productId);
    if (index == -1) return;

    final item = items[index];

    if (newQuantity < 1) {
      await removeFromCart(productId);
      return;
    }

    if (newQuantity > item.stock) {
      GlassFeedback.showSnackbar(
        title: 'Maksimum Stok',
        message: 'Maksimum pembelian adalah ${item.stock} ${item.unit}',
        isError: true,
      );
      return;
    }

    item.quantity = newQuantity;
    items[index] = item;
    await DatabaseHelper.saveCartItem(item);
  }

  Future<void> removeFromCart(String productId) async {
    items.removeWhere((i) => i.productId == productId);
    await DatabaseHelper.deleteCartItem(_currentUserId, productId);
    GlassFeedback.showSnackbar(
      title: 'Item Dihapus',
      message: 'Item telah dihapus dari keranjang belanja.',
    );
  }

  Future<void> toggleSelection(String productId, bool isSelected) async {
    final index = items.indexWhere((i) => i.productId == productId);
    if (index != -1) {
      items[index].isSelected = isSelected;
      items.refresh();
      await DatabaseHelper.saveCartItem(items[index]);
    }
  }

  Future<void> toggleSelectAll(bool selectAll) async {
    for (var item in items) {
      item.isSelected = selectAll;
      await DatabaseHelper.saveCartItem(item);
    }
    items.refresh();
  }

  Future<void> removePurchased(List<String> productIds) async {
    for (var id in productIds) {
      items.removeWhere((i) => i.productId == id);
      await DatabaseHelper.deleteCartItem(_currentUserId, id);
    }
  }

  Future<void> clearCart() async {
    await DatabaseHelper.clearCart(_currentUserId);
    items.clear();
  }

  // ---------------------------------------------------------------------------
  // WISHLIST: Operasi SQLite
  // ---------------------------------------------------------------------------
  Future<void> loadWishlist() async {
    try {
      final list = await DatabaseHelper.getWishlist(_currentUserId);
      wishlistItems.assignAll(list);
    } catch (_) {}
  }

  bool isFavorite(String productId) {
    return wishlistItems.any((item) => item.id == productId);
  }

  Future<void> toggleFavorite(ProductModel product) async {
    final exists = isFavorite(product.id);

    if (exists) {
      await DatabaseHelper.removeWishlist(_currentUserId, product.id);
      wishlistItems.removeWhere((item) => item.id == product.id);
      GlassFeedback.showSnackbar(
        title: 'Dihapus dari Wishlist',
        message: '${product.name} dihapus dari daftar produk favorit.',
      );
    } else {
      await DatabaseHelper.addWishlist(_currentUserId, product);
      wishlistItems.add(product);
      GlassFeedback.showSnackbar(
        title: 'Disimpan ke Wishlist',
        message: '${product.name} ditambahkan ke favorit.',
      );
    }
    update();
  }

  List<ProductModel> getWishlistItems() => wishlistItems;

  Future<void> remove(String productId) async {
    await DatabaseHelper.removeWishlist(_currentUserId, productId);
    wishlistItems.removeWhere((item) => item.id == productId);
    update();
  }

  NotificationController get _notifCtrl => Get.isRegistered<NotificationController>()
      ? Get.find<NotificationController>()
      : Get.put(NotificationController());

  // ---------------------------------------------------------------------------
  // PESANAN & CHECKOUT: Operasi API & SQLite
  // ---------------------------------------------------------------------------
  Future<void> loadOrders() async {
    try {
      isLoadingOrders.value = true;
      final apiList = await apiService.getOrders(_currentUserId);
      final dbList = await DatabaseHelper.getOrders(_currentUserId);

      final Map<String, OrderModel> map = {};
      for (var o in dbList) {
        map[o.id] = o;
      }
      for (var o in apiList) {
        map[o.id] = o;
      }
      final combined = map.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      orders.assignAll(combined);
    } catch (_) {
      try {
        final dbList = await DatabaseHelper.getOrders(_currentUserId);
        orders.assignAll(dbList);
      } catch (_) {}
    } finally {
      isLoadingOrders.value = false;
    }
  }

  Future<OrderModel?> placeOrder({
    required AddressModel address,
    required List<CartItemModel> selectedItems,
    required double shippingCost,
  }) async {
    if (selectedItems.isEmpty) {
      GlassFeedback.showSnackbar(
        title: 'Keranjang Kosong',
        message: 'Pilih minimal satu item untuk checkout.',
        isError: true,
      );
      return null;
    }

    try {
      isSubmitting.value = true;

      // 1. Panggil API pembuatan pesanan
      final subtotal = selectedItems.fold(0.0, (sum, item) => sum + item.subtotal);
      final total = subtotal + shippingCost;
      final orderNumber = ApiService.generateOrderNumber();
      final initialStatus = (selectedPaymentMethod.value.toUpperCase() == 'COD')
          ? 'Diproses'
          : 'Menunggu Pembayaran';

      final orderItems = selectedItems
          .map((item) => OrderItemModel(
                productId: item.productId,
                name: item.name,
                price: item.price,
                unit: item.unit,
                quantity: item.quantity,
                subtotal: item.subtotal,
              ))
          .toList();

      final orderData = {
        'id': 'ord_${DateTime.now().millisecondsSinceEpoch}',
        'orderNumber': orderNumber,
        'userId': _currentUserId,
        'createdAt': DateTime.now().toIso8601String(),
        'status': initialStatus,
        'paymentMethod': selectedPaymentMethod.value,
        'address': address.toJson(),
        'subtotal': subtotal,
        'shippingCost': shippingCost,
        'total': total,
        'items': orderItems.map((i) => i.toJson()).toList(),
      };

      final createdOrder = await apiService.createOrder(orderData);

      // Simpan ke database lokal SQLite untuk persistensi permanen
      await DatabaseHelper.saveOrder(createdOrder);

      // 2. Hapus HANYA item yang dibeli dari keranjang lokal & SQLite
      final purchasedIds = selectedItems.map((i) => i.productId).toList();
      await removePurchased(purchasedIds);

      // 3. Tambahkan ke daftar orders lokal
      orders.insert(0, createdOrder);
      currentOrder.value = createdOrder;

      // 4. Catat notifikasi aktivitas pesanan secara otomatis ke NotificationController & SQLite
      try {
        await _notifCtrl.addOrderNotification(
          title: 'Pesanan Berhasil Dibuat',
          status: createdOrder.status,
          orderNumber: createdOrder.orderNumber,
          message: 'Pesanan ${createdOrder.orderNumber} berhasil dibuat dengan total Rp ${createdOrder.total.toInt()}. Menunggu konfirmasi pembayaran.',
          orderId: createdOrder.id,
        );
      } catch (notifErr) {
        debugPrint('Notifikasi error: $notifErr');
      }

      return createdOrder;
    } catch (e) {
      GlassFeedback.showSnackbar(
        title: 'Checkout Gagal',
        message: e.toString().replaceAll('Exception: ', '').replaceAll('HttpException: ', ''),
        isError: true,
      );
      return null;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> advanceStatus(String orderId) async {
    final index = orders.indexWhere((o) => o.id == orderId);
    if (index == -1) return;

    final currentStatus = orders[index].status;
    String nextStatus = currentStatus;

    switch (currentStatus) {
      case 'Menunggu Pembayaran':
        nextStatus = 'Diproses';
        break;
      case 'Diproses':
        nextStatus = 'Dikemas';
        break;
      case 'Dikemas':
        nextStatus = 'Dikirim';
        break;
      case 'Dikirim':
        nextStatus = 'Selesai';
        break;
      default:
        return;
    }

    try {
      final updated = await apiService.updateOrderStatus(orderId, nextStatus);
      orders[index] = updated;
      if (currentOrder.value?.id == orderId) {
        currentOrder.value = updated;
      }
      orders.refresh();
      await DatabaseHelper.updateOrderStatus(orderId, nextStatus);

      // Catat pembaruan status ke sistem notifikasi
      try {
        await _notifCtrl.addOrderNotification(
          title: 'Status Pesanan Diperbarui',
          status: nextStatus,
          orderNumber: updated.orderNumber,
          message: 'Status pesanan ${updated.orderNumber} saat ini telah diperbarui menjadi $nextStatus.',
          orderId: updated.id,
        );
      } catch (_) {}

      GlassFeedback.showSnackbar(
        title: 'Status Diperbarui',
        message: 'Status pesanan berubah menjadi: $nextStatus',
      );
    } catch (e) {
      GlassFeedback.showSnackbar(
        title: 'Gagal Memperbarui Status',
        message: e.toString(),
        isError: true,
      );
    }
  }

  Future<void> cancelOrder(String orderId) async {
    final index = orders.indexWhere((o) => o.id == orderId);
    if (index == -1) return;

    final currentStatus = orders[index].status;
    if (currentStatus != 'Menunggu Pembayaran' && currentStatus != 'Diproses') {
      GlassFeedback.showSnackbar(
        title: 'Tidak Dapat Dibatalkan',
        message: 'Pesanan yang sudah dalam proses pengiriman tidak dapat dibatalkan.',
        isError: true,
      );
      return;
    }

    try {
      final updated = await apiService.updateOrderStatus(orderId, 'Dibatalkan');
      orders[index] = updated;
      if (currentOrder.value?.id == orderId) {
        currentOrder.value = updated;
      }
      orders.refresh();
      await DatabaseHelper.updateOrderStatus(orderId, 'Dibatalkan');

      // Catat notifikasi pembatalan pesanan
      try {
        await _notifCtrl.addOrderNotification(
          title: 'Pesanan Dibatalkan',
          status: 'Dibatalkan',
          orderNumber: updated.orderNumber,
          message: 'Pesanan ${updated.orderNumber} telah dibatalkan oleh pengguna.',
          orderId: updated.id,
        );
      } catch (_) {}

      GlassFeedback.showSnackbar(
        title: 'Pesanan Dibatalkan',
        message: 'Pesanan ${updated.orderNumber} telah dibatalkan.',
      );
    } catch (e) {
      GlassFeedback.showSnackbar(
        title: 'Gagal Membatalkan Pesanan',
        message: e.toString(),
        isError: true,
      );
    }
  }

  Future<bool> updatePaymentMethod(String orderId, String newMethod) async {
    final index = orders.indexWhere((o) => o.id == orderId);
    if (index == -1) return false;

    final targetOrder = orders[index];
    if (targetOrder.status == 'Selesai' || targetOrder.status == 'Dibatalkan') {
      GlassFeedback.showSnackbar(
        title: 'Tidak Dapat Diubah',
        message: 'Metode pembayaran untuk pesanan yang sudah selesai atau dibatalkan tidak dapat diubah.',
        isError: true,
      );
      return false;
    }

    try {
      final updated = await apiService.updateOrderPaymentMethod(orderId, newMethod);
      orders[index] = updated;
      if (currentOrder.value?.id == orderId) {
        currentOrder.value = updated;
      }
      orders.refresh();
      await DatabaseHelper.updateOrderPaymentMethod(orderId, newMethod);

      // Catat ke daftar notifikasi
      try {
        await _notifCtrl.addOrderNotification(
          title: 'Metode Pembayaran Diubah',
          status: newMethod,
          orderNumber: updated.orderNumber,
          message: 'Metode pembayaran untuk pesanan ${updated.orderNumber} berhasil dialihkan ke $newMethod.',
          orderId: updated.id,
        );
      } catch (_) {}

      GlassFeedback.showSnackbar(
        title: 'Metode Pembayaran Diperbarui',
        message: 'Metode pembayaran pesanan ${updated.orderNumber} diubah ke $newMethod.',
      );
      return true;
    } catch (e) {
      GlassFeedback.showSnackbar(
        title: 'Gagal Memperbarui Metode Pembayaran',
        message: e.toString(),
        isError: true,
      );
      return false;
    }
  }
}

/// ============================================================================
/// TYPEDEFS & ALIAS KOMPATIBILITAS
/// Memastikan seluruh View dan Unit Test yang memanggil nama lama tetap berjalan
/// ============================================================================
typedef CartController = ShopController;
typedef WishlistController = ShopController;
typedef ProductController = ShopController;
typedef OrderController = ShopController;
