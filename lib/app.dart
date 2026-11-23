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
/// 1. SISTEM WARNA & TEMA (WIJI BUMI - DARK FOREST GREEN & LIQUID GLASS)
/// ============================================================================
class WijiBumiColors {
  // Palet Utama (Dark Forest Green & High-Contrast Liquid Glass)
  static const Color bgPrimary = Color(0xFF1C2B1E);       // Latar utama (hijau hutan gelap)
  static const Color backgroundCanvas = Color(0xFF1C2B1E); // Canvas halaman
  static const Color surfaceDark = Color(0xFF142117);     // Hijau hutan sangat pekat
  static const Color emerald = Color(0xFF2D5A38);         // Hijau zamrud
  static const Color surfaceGlass = Color(0x24FFFFFF);    // Kaca transparan
  static const Color glassBorder = Color(0x47FFFFFF);     // Border kilau kaca (0.28 white)
  static const Color textWhite = Color(0xFFFFFFFF);       // Teks putih bersih
  static const Color textLightGreen = Color(0xFFC8DDD0);  // Hijau sage terang
  static const Color textPrimary = Color(0xFFFFFFFF);     // WAJIB PUTIH BERSIH untuk judul, harga, dan data di atas kaca
  static const Color textSecondary = Color(0xFFC8DDD0);   // WAJIB HIJAU SAGE TERANG untuk label, deskripsi, dan waktu
  static const Color textMuted = Color(0xFFC8DDD0);       // Hijau sage terang
  static const Color textMutedLight = Color(0xFFC8DDD0);  // Kompatibilitas teks subjudul
  static const Color textPlaceholder = Color(0xFF9EB5A4); // Placeholder input
  static const Color textCardDark = Color(0xFFFFFFFF);    // Teks di atas kartu kaca (putih bersih)
  static const Color iconNavInactive = Color(0xFF9EB5A4); // Ikon nav pasif
  static const Color shadowObject = Color(0x33000000);    // Bayangan kartu

  // Aksen Hijau Botani & Mint Cerah
  static const Color lightMint = Color(0x22FFFFFF);       // Latar badge/pill kaca lembut
  static const Color softSage = Color(0x47FFFFFF);        // Border aksen kaca
  static const Color borderSage = Color(0x47FFFFFF);      // Border kartu kaca (0.28 white)
  static const Color freshLeaf = Color(0xFFA7F3D0);       // Hijau mint cerah
  static const Color deepForest = Color(0xFF1C2B1E);      // Hijau hutan gelap
  static const Color pureGlassWhite = Color(0xFFFFFFFF);  // Kartu putih murni
  static const Color accentBright = Color(0xFFA7F3D0);    // Mint cerah untuk tombol aktif

  // Status Indikator
  static const Color error = Color(0xFFFF5252);
  static const Color warning = Color(0xFFFFB74D);
  static const Color success = Color(0xFF4ADE80);
  static const Color starGold = Color(0xFFFFD54F);
}

class DynamicGlassDecoration {
  /// Liquid Glass di atas area hijau gelap (Beranda atas, Search, Nav Header)
  static BoxDecoration liquidGlassDark({double radius = 16}) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.16),
          const Color(0xFF2A3F2D).withOpacity(0.65),
        ],
      ),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: Colors.white.withOpacity(0.28),
        width: 1.2,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.20),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Liquid Glass untuk kartu konten di seluruh aplikasi
  static BoxDecoration glassCard({double radius = 16}) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.14),
          const Color(0xFF2A3F2D).withOpacity(0.65),
        ],
      ),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: Colors.white.withOpacity(0.28),
        width: 1.2,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.22),
          blurRadius: 16,
          offset: const Offset(0, 4),
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
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF1C2B1E).withOpacity(0.92),
          const Color(0xFF243827).withOpacity(0.92),
        ],
      ),
      borderRadius: BorderRadius.vertical(
        top: fullTopRadius ? Radius.circular(radius) : Radius.zero,
        bottom: fullBottomRadius ? Radius.circular(radius) : Radius.zero,
      ),
      border: Border.all(
        color: Colors.white.withOpacity(0.28),
        width: 1.2,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.25),
          blurRadius: 18,
          offset: const Offset(0, -3),
        ),
      ],
    );
  }

  static BoxDecoration cleanCard({double radius = 16}) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.13),
          const Color(0xFF233826).withOpacity(0.70),
        ],
      ),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: Colors.white.withOpacity(0.25),
        width: 1.2,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.18),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static BoxDecoration accentPill({double radius = 12, Color? fillColor, Color? borderColor}) {
    return BoxDecoration(
      color: fillColor ?? Colors.white.withOpacity(0.12),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: borderColor ?? Colors.white.withOpacity(0.25),
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
      fillColor: Colors.white.withOpacity(0.10),
      hintStyle: const TextStyle(color: Color(0xFF9EB5A4), fontSize: 13),
      labelStyle: const TextStyle(color: Color(0xFFC8DDD0), fontSize: 13, fontWeight: FontWeight.w600),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.25), width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.25), width: 1.0),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Color(0xFFA7F3D0), width: 1.6),
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
        surface: Colors.white,
        error: WijiBumiColors.error,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: WijiBumiColors.deepForest,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 16.5,
          fontWeight: FontWeight.w700,
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
