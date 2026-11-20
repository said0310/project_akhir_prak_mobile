import 'package:get/get.dart';
import '../controllers/location_controller.dart';
import '../../../data/repositories/address_repository.dart';

class LocationBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<LocationController>()) {
      Get.lazyPut<LocationController>(
        () => LocationController(addressRepository: Get.find<AddressRepository>()),
      );
    }
  }
}
