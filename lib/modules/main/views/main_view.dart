import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/main_controller.dart';
import '../../home/views/home_view.dart';
import '../../cart/views/cart_view.dart';
import '../../profile/views/profile_view.dart';
import '../../cart/controllers/cart_controller.dart';

class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    final mainController = Get.find<MainController>();
    final cartController = Get.find<CartController>();

    const List<Widget> pages = [
      HomeView(),
      CartView(),
      ProfileView(),
    ];

    return Obx(
      () => Scaffold(
        backgroundColor: WijiBumiColors.bgPrimary,
        body: IndexedStack(
          index: mainController.currentTabIndex.value,
          children: pages,
        ),
        extendBody: true,
        // Bottom Navigation Bar Frosted Glass (3 Tab: Beranda, Keranjang, Profil)
        bottomNavigationBar: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(36),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              width: double.infinity,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.24),
                    const Color(0xFF18261A).withOpacity(0.72),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(36),
                ),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withOpacity(0.35),
                    width: 1.2,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.35),
                    blurRadius: 24,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildNavItem(
                    index: 0,
                    icon: Icons.home_rounded,
                    controller: mainController,
                  ),
                  _buildCartNavItem(
                    index: 1,
                    icon: Icons.eco_rounded,
                    controller: mainController,
                    cartController: cartController,
                  ),
                  _buildNavItem(
                    index: 2,
                    icon: Icons.person_rounded,
                    controller: mainController,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required MainController controller,
  }) {
    final isSelected = controller.currentTabIndex.value == index;

    return GestureDetector(
      onTap: () => controller.changeTab(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.28),
                  width: 1.0,
                ),
              )
            : null,
        child: Icon(
          icon,
          size: 27,
          color: isSelected
              ? WijiBumiColors.textWhite
              : WijiBumiColors.iconNavInactive,
        ),
      ),
    );
  }

  Widget _buildCartNavItem({
    required int index,
    required IconData icon,
    required MainController controller,
    required CartController cartController,
  }) {
    final isSelected = controller.currentTabIndex.value == index;

    return GestureDetector(
      onTap: () => controller.changeTab(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.28),
                  width: 1.0,
                ),
              )
            : null,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              icon,
              size: 27,
              color: isSelected
                  ? WijiBumiColors.textWhite
                  : WijiBumiColors.iconNavInactive,
            ),
            Obx(() {
              final count = cartController.totalItemCount;
              if (count == 0) return const SizedBox.shrink();

              return Positioned(
                top: -4,
                right: -6,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: WijiBumiColors.textWhite,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 15,
                    minHeight: 15,
                  ),
                  child: Center(
                    child: Text(
                      count > 99 ? '99+' : '$count',
                      style: const TextStyle(
                        color: Color(0xFF18261A),
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
