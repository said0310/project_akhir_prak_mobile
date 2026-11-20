import 'package:get/get.dart';
import '../../../data/models/product_model.dart';
import '../../../storage/hive_service.dart';
import '../../../widgets/glass_feedback.dart';
import '../../auth/controllers/auth_controller.dart';

class WishlistController extends GetxController {
  String get _currentUserId {
    if (Get.isRegistered<AuthController>()) {
      return Get.find<AuthController>().currentUser.value?.id ?? 'guest';
    }
    return 'guest';
  }

  String _getKey(String productId) => '${_currentUserId}_$productId';

  bool isFavorite(String productId) {
    return HiveService.wishlistBox.containsKey(_getKey(productId));
  }

  void toggleFavorite(ProductModel product) {
    final key = _getKey(product.id);
    final box = HiveService.wishlistBox;

    if (box.containsKey(key)) {
      box.delete(key);
      GlassFeedback.showSnackbar(
        title: 'Dihapus dari Wishlist',
        message: '${product.name} dihapus dari daftar produk favorit.',
      );
    } else {
      box.put(key, product);
      GlassFeedback.showSnackbar(
        title: 'Disimpan ke Wishlist',
        message: '${product.name} ditambahkan ke favorit.',
      );
    }
    update();
  }

  List<ProductModel> getWishlistItems() {
    return HiveService.wishlistBox.values.toList();
  }

  void remove(String productId) {
    HiveService.wishlistBox.delete(_getKey(productId));
    update();
  }
}
