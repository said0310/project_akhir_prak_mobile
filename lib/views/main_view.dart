import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app.dart';
import '../controllers/shop_controller.dart';
import 'home_view.dart';
import 'order_history_view.dart';
import 'cart_view.dart';
import 'profile_view.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _currentTabIndex = 0;

  void changeTab(int index) {
    setState(() {
      _currentTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final shopController = Get.find<ShopController>();

    final List<Widget> pages = [
      const HomeView(),
      const OrderHistoryView(isEmbedded: true),
      const CartView(),
      const ProfileView(),
    ];

    return Scaffold(
      backgroundColor: WijiBumiColors.backgroundCanvas,
      body: IndexedStack(
        index: _currentTabIndex,
        children: pages,
      ),
      extendBody: true,
      // Bottom Navigation Bar Floating Liquid Glass (4 Tab: Beranda, Pesanan Saya, Keranjang, Profil)
      bottomNavigationBar: SafeArea(
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                width: double.infinity,
                height: 68,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF1C2B1E).withOpacity(0.94),
                      const Color(0xFF243827).withOpacity(0.94),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.28),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
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
                    ),
                    _buildOrderNavItem(
                      index: 1,
                      icon: Icons.local_shipping_rounded,
                      shopController: shopController,
                    ),
                    _buildCartNavItem(
                      index: 2,
                      icon: Icons.shopping_cart_rounded,
                      shopController: shopController,
                    ),
                    _buildNavItem(
                      index: 3,
                      icon: Icons.person_rounded,
                    ),
                  ],
                ),
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
  }) {
    final isSelected = _currentTabIndex == index;

    return GestureDetector(
      onTap: () => changeTab(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                color: const Color(0xFF142117),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.28),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              )
            : null,
        child: Icon(
          icon,
          size: 24,
          color: isSelected
              ? const Color(0xFFA7F3D0)
              : const Color(0xFF9EB5A4),
        ),
      ),
    );
  }

  Widget _buildOrderNavItem({
    required int index,
    required IconData icon,
    required ShopController shopController,
  }) {
    final isSelected = _currentTabIndex == index;

    return GestureDetector(
      onTap: () => changeTab(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                color: WijiBumiColors.deepForest,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: WijiBumiColors.deepForest.withOpacity(0.30),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              )
            : null,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected
                  ? Colors.white
                  : WijiBumiColors.iconNavInactive,
            ),
            Obx(() {
              final activeCount = shopController.orders
                  .where((o) => o.status != 'Selesai' && o.status != 'Dibatalkan')
                  .length;
              if (activeCount == 0) return const SizedBox.shrink();

              return Positioned(
                top: -4,
                right: -6,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF81C784) : WijiBumiColors.freshLeaf,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 15,
                    minHeight: 15,
                  ),
                  child: Center(
                    child: Text(
                      activeCount > 99 ? '99+' : '$activeCount',
                      style: TextStyle(
                        color: isSelected ? WijiBumiColors.deepForest : Colors.white,
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

  Widget _buildCartNavItem({
    required int index,
    required IconData icon,
    required ShopController shopController,
  }) {
    final isSelected = _currentTabIndex == index;

    return GestureDetector(
      onTap: () => changeTab(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                color: WijiBumiColors.deepForest,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: WijiBumiColors.deepForest.withOpacity(0.30),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              )
            : null,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected
                  ? Colors.white
                  : WijiBumiColors.iconNavInactive,
            ),
            Obx(() {
              final count = shopController.totalItemCount;
              if (count == 0) return const SizedBox.shrink();

              return Positioned(
                top: -4,
                right: -6,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF81C784) : WijiBumiColors.freshLeaf,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 15,
                    minHeight: 15,
                  ),
                  child: Center(
                    child: Text(
                      count > 99 ? '99+' : '$count',
                      style: TextStyle(
                        color: isSelected ? WijiBumiColors.deepForest : Colors.white,
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
