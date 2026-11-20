import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/services/notification_service.dart';
import 'storage/pref_service.dart';
import 'storage/hive_service.dart';
import 'app/bindings/initial_binding.dart';
import 'app/routes/app_pages.dart';

void main() async {
  // 1. Pastikan Flutter Binding terinisialisasi
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inisialisasi Lokalisasi Tanggal (id_ID)
  try {
    await initializeDateFormatting('id_ID', null);
  } catch (e) {
    debugPrint('Date formatting init note: $e');
  }

  // 3. Inisialisasi SharedPreferences (Modul VI)
  final prefService = await PrefService().init();
  Get.put<PrefService>(prefService, permanent: true);

  // 4. Inisialisasi Hive & TypeAdapters (Modul VI)
  await HiveService.init();

  // 5. Inisialisasi Local Notification & Timezone (Modul VII-A)
  await NotificationService.init();

  // 6. Jalankan Aplikasi
  runApp(const WijiBumiApp());
}

class WijiBumiApp extends StatelessWidget {
  const WijiBumiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialBinding: InitialBinding(),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      defaultTransition: Transition.cupertino,
    );
  }
}
