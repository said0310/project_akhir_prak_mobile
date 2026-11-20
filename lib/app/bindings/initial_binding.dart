import 'package:get/get.dart';
import '../../data/providers/api_service.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/order_repository.dart';
import '../../data/repositories/address_repository.dart';
import '../../storage/pref_service.dart';
import '../../modules/auth/controllers/auth_controller.dart';
import '../../modules/cart/controllers/cart_controller.dart';
import '../../modules/main/controllers/main_controller.dart';
import '../../modules/product/controllers/product_controller.dart';
import '../../modules/order/controllers/order_controller.dart';
import '../../modules/location/controllers/location_controller.dart';
import '../../modules/notification/controllers/notification_controller.dart';
import '../../modules/wishlist/controllers/wishlist_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // 1. Storage & Services
    final prefService = Get.find<PrefService>();
    final apiService = ApiService();
    Get.lazyPut<ApiService>(() => apiService);

    // 2. Repositories
    final authRepo = AuthRepository(apiService: apiService, prefService: prefService);
    final productRepo = ProductRepository(apiService: apiService);
    final orderRepo = OrderRepository(apiService: apiService);
    final addressRepo = AddressRepository();

    Get.lazyPut<AuthRepository>(() => authRepo);
    Get.lazyPut<ProductRepository>(() => productRepo);
    Get.lazyPut<OrderRepository>(() => orderRepo);
    Get.lazyPut<AddressRepository>(() => addressRepo);

    // 3. Global Controllers (Wajib Get.put sesuai PRD Bagian 16-B)
    Get.put<AuthController>(AuthController(authRepository: authRepo), permanent: true);
    Get.put<CartController>(CartController(), permanent: true);

    // 4. Feature Controllers
    Get.lazyPut<MainController>(() => MainController(), fenix: true);
    Get.lazyPut<ProductController>(() => ProductController(productRepository: productRepo), fenix: true);
    Get.lazyPut<OrderController>(() => OrderController(orderRepository: orderRepo), fenix: true);
    Get.lazyPut<LocationController>(() => LocationController(addressRepository: addressRepo), fenix: true);
    Get.lazyPut<NotificationController>(() => NotificationController(), fenix: true);
    Get.lazyPut<WishlistController>(() => WishlistController(), fenix: true);
  }
}
