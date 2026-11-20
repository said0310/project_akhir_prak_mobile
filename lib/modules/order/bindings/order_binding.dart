import 'package:get/get.dart';
import '../controllers/order_controller.dart';
import '../../../data/repositories/order_repository.dart';

class OrderBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<OrderController>()) {
      Get.lazyPut<OrderController>(
        () => OrderController(orderRepository: Get.find<OrderRepository>()),
      );
    }
  }
}
