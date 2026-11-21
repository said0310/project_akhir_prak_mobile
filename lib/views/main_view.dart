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
      backgroundColor: WijiBumiColors.bgPrimary,
      body: IndexedStack(
        index: _currentTabIndex,
        children: pages,
      ),
      extendBody: true,
      // Bottom Navigation Bar Frosted Glass (4 Tab: Beranda, Pesanan Saya, Keranjang, Profil)
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
              final activeCount = shopController.orders
                  .where((o) => o.status != 'Selesai' && o.status != 'Dibatalkan')
                  .length;
              if (activeCount == 0) return const SizedBox.shrink();

              return Positioned(
                top: -4,
                right: -6,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: WijiBumiColors.freshLeaf,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 15,
                    minHeight: 15,
                  ),
                  child: Center(
                    child: Text(
                      activeCount > 99 ? '99+' : '$activeCount',
                      style: const TextStyle(
                        color: Colors.white,
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
              final count = shopController.totalItemCount;
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
