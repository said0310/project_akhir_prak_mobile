import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'app.dart';
import 'services/api_service.dart';
import 'services/database_helper.dart';
import 'services/notification_service.dart';
import 'services/map_service.dart';

void main() async {
  // 1. Pastikan Flutter Binding terinisialisasi
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inisialisasi sqflite FFI untuk Windows/Linux/macOS desktop
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // 3. Inisialisasi Lokalisasi Tanggal (id_ID)
  try {
    await initializeDateFormatting('id_ID', null);
  } catch (e) {
    debugPrint('Date formatting init note: $e');
  }

  // 4. Inisialisasi SharedPreferences (Sesi Pengguna)
  final prefService = await PrefService().init();
  Get.put<PrefService>(prefService, permanent: true);

  // 5. Inisialisasi SQLite Database & Tabel
  await DatabaseHelper.init();

  // 6. Inisialisasi Local Notification & Timezone (hanya di mobile)
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    await NotificationService.init();
  }

  // 7. Muat Katalog Produk & Kategori dari CSV Lokal
  await ApiService.loadCatalogFromCsv();

  // 8. Inisialisasi Layanan Peta & API Key Google Maps
  await MapService.init();

  // 9. Jalankan Aplikasi
  runApp(const WijiBumiApp());
}
