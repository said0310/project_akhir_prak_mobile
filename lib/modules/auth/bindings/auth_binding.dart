import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../data/repositories/auth_repository.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthController>()) {
      Get.lazyPut<AuthController>(
        () => AuthController(authRepository: Get.find<AuthRepository>()),
      );
    }
  }
}
