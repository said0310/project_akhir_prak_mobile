import 'package:get/get.dart';
import 'app_routes.dart';
import '../bindings/initial_binding.dart';
import '../../modules/splash/views/splash_view.dart';
import '../../modules/auth/views/login_view.dart';
import '../../modules/auth/views/register_view.dart';
import '../../modules/auth/bindings/auth_binding.dart';
import '../../modules/main/views/main_view.dart';
import '../../modules/main/bindings/main_binding.dart';
import '../../modules/product/views/catalog_view.dart';
import '../../modules/product/views/product_detail_view.dart';
import '../../modules/product/bindings/product_binding.dart';
import '../../modules/cart/views/cart_view.dart';
import '../../modules/cart/bindings/cart_binding.dart';
import '../../modules/checkout/views/checkout_view.dart';
import '../../modules/order/views/order_success_view.dart';
import '../../modules/order/views/order_history_view.dart';
import '../../modules/order/views/order_detail_view.dart';
import '../../modules/order/bindings/order_binding.dart';
import '../../modules/location/views/address_view.dart';
import '../../modules/location/bindings/location_binding.dart';
import '../../modules/notification/views/reminder_view.dart';
import '../../modules/notification/bindings/notification_binding.dart';
import '../../modules/profile/views/profile_view.dart';
import '../../modules/profile/views/edit_profile_view.dart';
import '../../modules/profile/views/about_view.dart';

class AppPages {
  static const INITIAL = AppRoutes.SPLASH;

  static final routes = [
    GetPage(
      name: AppRoutes.SPLASH,
      page: () => const SplashView(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.REGISTER,
      page: () => const RegisterView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.MAIN,
      page: () => const MainView(),
      binding: MainBinding(),
    ),
    GetPage(
      name: AppRoutes.CATALOG,
      page: () => const CatalogView(),
      binding: ProductBinding(),
    ),
    GetPage(
      name: AppRoutes.PRODUCT_DETAIL,
      page: () => const ProductDetailView(),
      binding: ProductBinding(),
    ),
    GetPage(
      name: AppRoutes.CART,
      page: () => const CartView(),
      binding: CartBinding(),
    ),
    GetPage(
      name: AppRoutes.CHECKOUT,
      page: () => const CheckoutView(),
      binding: OrderBinding(),
    ),
    GetPage(
      name: AppRoutes.ADDRESS,
      page: () => const AddressView(),
      binding: LocationBinding(),
    ),
    GetPage(
      name: AppRoutes.ORDER_SUCCESS,
      page: () => const OrderSuccessView(),
      binding: OrderBinding(),
    ),
    GetPage(
      name: AppRoutes.ORDERS,
      page: () => const OrderHistoryView(),
      binding: OrderBinding(),
    ),
    GetPage(
      name: AppRoutes.ORDER_DETAIL,
      page: () => const OrderDetailView(),
      binding: OrderBinding(),
    ),
    GetPage(
      name: AppRoutes.REMINDERS,
      page: () => const ReminderView(),
      binding: NotificationBinding(),
    ),
    GetPage(
      name: AppRoutes.PROFILE,
      page: () => const ProfileView(),
      binding: MainBinding(),
    ),
    GetPage(
      name: AppRoutes.EDIT_PROFILE,
      page: () => const EditProfileView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.ABOUT,
      page: () => const AboutView(),
    ),
  ];
}
