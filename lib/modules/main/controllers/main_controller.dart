import 'package:get/get.dart';

class MainController extends GetxController {
  final RxInt currentTabIndex = 0.obs;

  void changeTab(int index) {
    currentTabIndex.value = index;
  }
}
