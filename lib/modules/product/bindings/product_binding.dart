import 'package:get/get.dart';
import '../controllers/product_controller.dart';
import '../../../data/repositories/product_repository.dart';

class ProductBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ProductController>()) {
      Get.lazyPut<ProductController>(
        () => ProductController(productRepository: Get.find<ProductRepository>()),
      );
    }
  }
}
