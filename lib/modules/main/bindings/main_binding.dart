import 'package:get/get.dart';
import '../controllers/main_controller.dart';
import '../../product/controllers/product_controller.dart';
import '../../order/controllers/order_controller.dart';
import '../../location/controllers/location_controller.dart';
import '../../notification/controllers/notification_controller.dart';
import '../../wishlist/controllers/wishlist_controller.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../data/repositories/address_repository.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<MainController>()) {
      Get.lazyPut<MainController>(() => MainController());
    }
    if (!Get.isRegistered<ProductController>()) {
      Get.lazyPut<ProductController>(
        () => ProductController(productRepository: Get.find<ProductRepository>()),
      );
    }
    if (!Get.isRegistered<OrderController>()) {
      Get.lazyPut<OrderController>(
        () => OrderController(orderRepository: Get.find<OrderRepository>()),
      );
    }
    if (!Get.isRegistered<LocationController>()) {
      Get.lazyPut<LocationController>(
        () => LocationController(addressRepository: Get.find<AddressRepository>()),
      );
    }
    if (!Get.isRegistered<NotificationController>()) {
      Get.lazyPut<NotificationController>(() => NotificationController());
    }
    if (!Get.isRegistered<WishlistController>()) {
      Get.lazyPut<WishlistController>(() => WishlistController());
    }
  }
}
