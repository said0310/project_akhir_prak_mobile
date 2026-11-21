import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

// Services & Repositories
import 'services/api_service.dart';
import 'services/database_helper.dart';

// Controllers
import 'controllers/auth_controller.dart';
import 'controllers/shop_controller.dart';
import 'controllers/location_controller.dart';
import 'controllers/notification_controller.dart';

// Views
import 'views/splash_view.dart';
import 'views/login_view.dart';
import 'views/register_view.dart';
import 'views/main_view.dart';
import 'views/product_detail_view.dart';
import 'views/cart_view.dart';
import 'views/checkout_view.dart';
import 'views/order_success_view.dart';
import 'views/order_history_view.dart';
import 'views/order_detail_view.dart';
import 'views/address_view.dart';
import 'views/reminder_view.dart';
import 'views/wishlist_view.dart';
import 'views/profile_view.dart';
import 'views/edit_profile_view.dart';
import 'views/about_view.dart';

/// ============================================================================
/// 1. SISTEM WARNA & TEMA (WIJI BUMI - ORGANIC GLASS THEME)
/// ============================================================================
class WijiBumiColors {
  static const Color bgPrimary = Color(0xFF243626);       // Latar utama (deep matte forest green)
  static const Color surfaceDark = Color(0xFF18261A);     // Surface gelap, search bar, bottom nav bar
  static const Color surfaceGlass = Color(0x66FFFFFF);    // Frosted glass
  static const Color glassBorder = Color(0x59FFFFFF);     // Border kaca
  static const Color textWhite = Color(0xFFFFFFFF);       // Heading, tab aktif, ikon
  static const Color textMutedLight = Color(0xFFC7DBC9);  // Sapaan Hello!, tab pasif
  static const Color textPlaceholder = Color(0xFF9CB89E); // Placeholder & caption
  static const Color textCardDark = Color(0xFF09170C);    // Teks dalam kartu
  static const Color iconNavInactive = Color(0xFF7E9881); // Ikon nav pasif
  static const Color shadowObject = Color(0x73040C05);

  // Aliases semantik
  static const Color lightMint = Color(0xFFE8F5E9);
  static const Color softSage = Color(0xFFA5D6A7);
  static const Color freshLeaf = Color(0xFF66BB6A);
  static const Color deepForest = Color(0xFF18261A);
  static const Color pureGlassWhite = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFC7DBC9);
  static const Color textMuted = Color(0xFF9CB89E);
  static const Color backgroundCanvas = Color(0xFF243626);

  // Status
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFA726);
  static const Color success = Color(0xFF43A047);
  static const Color starGold = Color(0xFFFFB300);
}

class DynamicGlassDecoration {
  static BoxDecoration glassCard({double radius = 30}) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.52),
          const Color(0xFFD8EADA).withOpacity(0.36),
        ],
      ),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: Colors.white.withOpacity(0.42),
        width: 1.2,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.24),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  static BoxDecoration glassBar({
    double radius = 16,
    bool fullTopRadius = true,
    bool fullBottomRadius = true,
  }) {
    return BoxDecoration(
      color: WijiBumiColors.surfaceDark,
      borderRadius: BorderRadius.vertical(
        top: fullTopRadius ? Radius.circular(radius) : Radius.zero,
        bottom: fullBottomRadius ? Radius.circular(radius) : Radius.zero,
      ),
      border: Border.all(
        color: Colors.white.withOpacity(0.14),
        width: 1.0,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.25),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static BoxDecoration cleanCard({double radius = 24}) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.48),
          const Color(0xFFD8EADA).withOpacity(0.32),
        ],
      ),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: Colors.white.withOpacity(0.38),
        width: 1.2,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.18),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  static BoxDecoration accentPill({double radius = 12, Color? fillColor, Color? borderColor}) {
    return BoxDecoration(
      color: fillColor ?? WijiBumiColors.surfaceDark,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: borderColor ?? Colors.white.withOpacity(0.20),
        width: 1.0,
      ),
    );
  }

  static InputDecoration inputDecoration({
    required String hintText,
    String? labelText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      labelText: labelText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white.withOpacity(0.92),
      hintStyle: const TextStyle(color: Color(0xFF757575), fontSize: 13),
      labelStyle: const TextStyle(color: WijiBumiColors.deepForest, fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: WijiBumiColors.softSage.withOpacity(0.8), width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: WijiBumiColors.softSage.withOpacity(0.8), width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: WijiBumiColors.freshLeaf, width: 1.6),
      ),
    );
  }
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: WijiBumiColors.backgroundCanvas,
      colorScheme: ColorScheme.fromSeed(
        seedColor: WijiBumiColors.deepForest,
        primary: WijiBumiColors.deepForest,
        secondary: WijiBumiColors.freshLeaf,
        surface: WijiBumiColors.pureGlassWhite,
        error: WijiBumiColors.error,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: IconThemeData(color: WijiBumiColors.textWhite),
        titleTextStyle: TextStyle(
          color: WijiBumiColors.textWhite,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }
}

/// ============================================================================
/// 2. ROUTING SISTEM (APP ROUTES & PAGES)
/// ============================================================================
abstract class AppRoutes {
  static const SPLASH = '/splash';
  static const LOGIN = '/login';
  static const REGISTER = '/register';
  static const MAIN = '/main';
  static const CATALOG = '/catalog';
  static const PRODUCT = '/product';
  static const PRODUCT_DETAIL = '/product/:id';
  static const CART = '/cart';
  static const CHECKOUT = '/checkout';
  static const ADDRESS = '/address';
  static const ORDER_SUCCESS = '/order-success';
  static const ORDERS = '/orders';
  static const ORDER_DETAIL = '/orders/detail';
  static const REMINDERS = '/reminders';
  static const WISHLIST = '/wishlist';
  static const PROFILE = '/profile';
  static const EDIT_PROFILE = '/profile/edit';
  static const ABOUT = '/about';
}

class AppPages {
  static const INITIAL = AppRoutes.SPLASH;

  static final routes = [
    GetPage(name: AppRoutes.SPLASH, page: () => const SplashView()),
    GetPage(name: AppRoutes.LOGIN, page: () => const LoginView()),
    GetPage(name: AppRoutes.REGISTER, page: () => const RegisterView()),
    GetPage(name: AppRoutes.MAIN, page: () => const MainView()),
    GetPage(name: AppRoutes.CATALOG, page: () => const MainView()),
    GetPage(name: AppRoutes.PRODUCT_DETAIL, page: () => const ProductDetailView()),
    GetPage(name: AppRoutes.CART, page: () => const CartView()),
    GetPage(name: AppRoutes.CHECKOUT, page: () => const CheckoutView()),
    GetPage(name: AppRoutes.ADDRESS, page: () => const AddressView()),
    GetPage(name: AppRoutes.ORDER_SUCCESS, page: () => const OrderSuccessView()),
    GetPage(name: AppRoutes.ORDERS, page: () => const OrderHistoryView()),
    GetPage(name: AppRoutes.ORDER_DETAIL, page: () => const OrderDetailView()),
    GetPage(name: AppRoutes.REMINDERS, page: () => const ReminderView()),
    GetPage(name: AppRoutes.PROFILE, page: () => const ProfileView()),
    GetPage(name: AppRoutes.EDIT_PROFILE, page: () => const EditProfileView()),
    GetPage(name: AppRoutes.ABOUT, page: () => const AboutView()),
    GetPage(name: AppRoutes.WISHLIST, page: () => const WishlistView()),
  ];
}

/// ============================================================================
/// 3. DEPENDENCY INJECTION (INITIAL BINDING)
/// ============================================================================
class AppBinding extends Bindings {
  @override
  void dependencies() {
    // 1. Service & Penyimpanan
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

    // 3. Global Controllers
    Get.put<AuthController>(AuthController(authRepository: authRepo), permanent: true);

    // ShopController menggantikan Cart, Product, Wishlist, dan Order controllers
    Get.put<ShopController>(
      ShopController(apiService: apiService),
      permanent: true,
    );

    // 4. Feature Controllers untuk Izin GPS & Notifikasi
    Get.lazyPut<LocationController>(() => LocationController(addressRepository: addressRepo), fenix: true);
    Get.lazyPut<NotificationController>(() => NotificationController(), fenix: true);
  }
}

/// Alias kompatibilitas
typedef InitialBinding = AppBinding;

/// ============================================================================
/// 4. WIDGET ROOT APLIKASI
/// ============================================================================
class WijiBumiApp extends StatelessWidget {
  const WijiBumiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Wiji Bumi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialBinding: AppBinding(),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      defaultTransition: Transition.cupertino,
    );
  }
}
