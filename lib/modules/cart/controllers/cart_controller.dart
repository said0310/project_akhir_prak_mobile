import 'package:get/get.dart';
import '../../../data/models/cart_item_model.dart';
import '../../../data/models/product_model.dart';
import '../../../storage/hive_service.dart';
import '../../../widgets/glass_feedback.dart';
import '../../auth/controllers/auth_controller.dart';

class CartController extends GetxController {
  final RxList<CartItemModel> items = <CartItemModel>[].obs;

  String get _currentUserId {
    if (Get.isRegistered<AuthController>()) {
      return Get.find<AuthController>().currentUser.value?.id ?? 'guest';
    }
    return 'guest';
  }

  String _getKey(String productId) => '${_currentUserId}_$productId';

  @override
  void onInit() {
    super.onInit();
    loadFromHive();
  }

  /// Memuat isi keranjang dari Hive saat aplikasi dibuka (FR-CART-07)
  void loadFromHive() {
    try {
      final box = HiveService.cartBox;
      final userItems = box.values
          .where((item) => item.userId == _currentUserId)
          .toList();
      items.assignAll(userItems);
    } catch (_) {}
  }

  /// Total seluruh kuantitas item untuk badge AppBar (reaktif Obx)
  int get totalItemCount {
    return items.fold<int>(0, (sum, item) => sum + item.quantity);
  }

  /// Jumlah total harga item yang dipilih (isSelected == true) (FR-CART-05)
  double getTotalPrice() {
    return items
        .where((item) => item.isSelected)
        .fold<double>(0.0, (sum, item) => sum + item.subtotal);
  }

  /// Tambah produk ke keranjang (FR-CART-01, BR-03, BR-04)
  void addToCart(ProductModel product, [int quantity = 1]) {
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
      // Produk sudah ada di keranjang, tambah kuantitasnya
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
      // Simpan ke Hive
      HiveService.cartBox.put(_getKey(product.id), existingItem);
    } else {
      // Buat baris baru di keranjang
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
      // Simpan ke Hive
      HiveService.cartBox.put(_getKey(product.id), newItem);
    }

    GlassFeedback.showSnackbar(
      title: 'Masuk Keranjang',
      message: '${product.name} berhasil ditambahkan ($quantity ${product.unit}).',
    );
  }

  /// Ubah kuantitas item dengan batas 1..stok (FR-CART-02)
  void updateQuantity(String productId, int newQuantity) {
    final index = items.indexWhere((i) => i.productId == productId);
    if (index == -1) return;

    final item = items[index];

    if (newQuantity < 1) {
      removeFromCart(productId);
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
    HiveService.cartBox.put(_getKey(productId), item);
  }

  /// Hapus item dari keranjang (FR-CART-03)
  void removeFromCart(String productId) {
    items.removeWhere((i) => i.productId == productId);
    HiveService.cartBox.delete(_getKey(productId));
    GlassFeedback.showSnackbar(
      title: 'Item Dihapus',
      message: 'Item telah dihapus dari keranjang belanja.',
    );
  }

  /// Toggle centang beli per item (FR-CART-04)
  void toggleSelection(String productId, bool isSelected) {
    final index = items.indexWhere((i) => i.productId == productId);
    if (index != -1) {
      items[index].isSelected = isSelected;
      items.refresh();
      HiveService.cartBox.put(_getKey(productId), items[index]);
    }
  }

  /// Toggle pilih semua
  void toggleSelectAll(bool selectAll) {
    for (var item in items) {
      item.isSelected = selectAll;
      HiveService.cartBox.put(_getKey(item.productId), item);
    }
    items.refresh();
  }

  /// Hapus hanya item yang terbeli setelah checkout sukses (BR-12)
  void removePurchased(List<String> productIds) {
    for (var id in productIds) {
      items.removeWhere((i) => i.productId == id);
      HiveService.cartBox.delete(_getKey(id));
    }
  }

  /// Kosongkan seluruh keranjang
  void clearCart() {
    for (var item in items) {
      HiveService.cartBox.delete(_getKey(item.productId));
    }
    items.clear();
  }
}
