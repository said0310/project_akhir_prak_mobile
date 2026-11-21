import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

/// ============================================================================
/// 1. PREF SERVICE (PENYIMPANAN SESI & PREFERENSI VIA SHAREDPREFERENCES)
/// ============================================================================
class PrefService {
  static const String prefIsLoggedIn = 'is_logged_in';
  static const String prefUserId = 'user_id';
  static const String prefSessionToken = 'session_token';
  static const String prefThemeMode = 'theme_mode';
  static const String prefNotifEnabled = 'notif_enabled';

  late SharedPreferences _prefs;

  Future<PrefService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  bool get isLoggedIn => _prefs.getBool(prefIsLoggedIn) ?? false;
  String get userId => _prefs.getString(prefUserId) ?? '';
  String get sessionToken => _prefs.getString(prefSessionToken) ?? '';

  Future<void> saveSession({required String userId, required String token}) async {
    await _prefs.setBool(prefIsLoggedIn, true);
    await _prefs.setString(prefUserId, userId);
    await _prefs.setString(prefSessionToken, token);
  }

  Future<void> clearSession() async {
    await _prefs.setBool(prefIsLoggedIn, false);
    await _prefs.remove(prefUserId);
    await _prefs.remove(prefSessionToken);
  }

  String get themeMode => _prefs.getString(prefThemeMode) ?? 'light';
  Future<void> setThemeMode(String mode) async => await _prefs.setString(prefThemeMode, mode);

  bool get isNotifEnabled => _prefs.getBool(prefNotifEnabled) ?? true;
  Future<void> setNotifEnabled(bool enabled) async => await _prefs.setBool(prefNotifEnabled, enabled);
}

/// ============================================================================
/// 2. API SERVICE (JARINGAN & SIMULASI API RESTful)
/// ============================================================================
class ApiService {
  final http.Client client;
  final String baseUrl;
  static const Duration timeoutDuration = Duration(seconds: 15);

  // Toggle simulasi error jaringan untuk pengujian offline
  static bool simulateNetworkError = false;

  ApiService({
    http.Client? client,
    this.baseUrl = 'https://api.wijibumi.local/v1',
  }) : client = client ?? http.Client();

  // Generator nomor pesanan unik: WB-YYYYMMDD-XXXX (BR-07)
  static String generateOrderNumber() {
    final now = DateTime.now();
    final dateStr = DateFormat('yyyyMMdd').format(now);
    final randomDigits = (1000 + Random().nextInt(9000)).toString();
    return 'WB-$dateStr-$randomDigits';
  }

  // Hash password SHA-256 (FR-AUTH-06)
  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  // In-Memory Mock Data
  static final List<CategoryModel> _mockCategories = [
    CategoryModel(id: 'tanaman_hias', name: 'Big plants', icon: 'yard'),
    CategoryModel(id: 'sayuran', name: 'Outdoor', icon: 'grass'),
    CategoryModel(id: 'buah', name: 'Indoor', icon: 'apple'),
  ];

  static final List<ProductModel> _mockProducts = [
    ProductModel(
      id: 'p1',
      name: 'Bayam Hijau Organik',
      categoryId: 'sayuran',
      description: 'Bayam segar langsung dari kebun organik tanpa pestisida kimia. Kaya akan zat besi dan vitamin A.',
      price: 6500,
      unit: 'ikat',
      stock: 45,
      imageUrl: 'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=600&auto=format&fit=crop&q=80',
      sellerName: 'Kebun Tani Makmur',
      sellerLocation: 'Pasar Minggu, Jakarta Selatan',
      sellerLat: -6.2847,
      sellerLng: 106.8441,
      rating: 4.9,
    ),
    ProductModel(
      id: 'p2',
      name: 'Kangkung Hidroponik Segar',
      categoryId: 'sayuran',
      description: 'Kangkung renyah dibudidayakan secara hidroponik bersih, segar, dan siap masak untuk tumis lezat.',
      price: 5000,
      unit: 'ikat',
      stock: 30,
      imageUrl: 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=600&auto=format&fit=crop&q=80',
      sellerName: 'Hydro Fresh Garden',
      sellerLocation: 'Jagakarsa, Jakarta Selatan',
      sellerLat: -6.3312,
      sellerLng: 106.8288,
      rating: 4.8,
    ),
    ProductModel(
      id: 'p3',
      name: 'Brokoli Hijau Segar Pilihan',
      categoryId: 'sayuran',
      description: 'Brokoli hijau padat bebas ulat dengan kuntum segar berkualitas ekspor. Baik untuk daya tahan tubuh.',
      price: 18000,
      unit: 'kg',
      stock: 20,
      imageUrl: 'https://images.unsplash.com/photo-1584270354949-c26b0d5b4a0c?w=600&auto=format&fit=crop&q=80',
      sellerName: 'Sayur Lembang Lestari',
      sellerLocation: 'Cilandak, Jakarta Selatan',
      sellerLat: -6.2952,
      sellerLng: 106.8041,
      rating: 4.9,
    ),
    ProductModel(
      id: 'p4',
      name: 'Wortel Manis Brastagi',
      categoryId: 'sayuran',
      description: 'Wortel renyah manis asal Brastagi, kaya beta karoten untuk kesehatan mata dan jus segar.',
      price: 14000,
      unit: 'kg',
      stock: 35,
      imageUrl: 'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=600&auto=format&fit=crop&q=80',
      sellerName: 'Kebun Tani Makmur',
      sellerLocation: 'Pasar Minggu, Jakarta Selatan',
      sellerLat: -6.2847,
      sellerLng: 106.8441,
      rating: 4.7,
    ),
    ProductModel(
      id: 'p5',
      name: 'Monstera Deliciosa Dewasa',
      categoryId: 'tanaman_hias',
      description: 'Tanaman hias tropis daun sobek ikonik, cocok mempercantik sudut ruangan dan pembersih udara.',
      price: 125000,
      unit: 'pot',
      stock: 12,
      imageUrl: 'https://images.unsplash.com/photo-1614594975525-e45190c55d0b?w=600&auto=format&fit=crop&q=80',
      sellerName: 'Flora Asri Sentosa',
      sellerLocation: 'Tebet, Jakarta Selatan',
      sellerLat: -6.2297,
      sellerLng: 106.8580,
      rating: 5.0,
    ),
    ProductModel(
      id: 'p6',
      name: 'Sansevieria Lidah Mertua',
      categoryId: 'tanaman_hias',
      description: 'Tanaman hias tangguh penyerap racun udara dalam ruangan. Sangat mudah dirawat dan jarang layu.',
      price: 45000,
      unit: 'pot',
      stock: 25,
      imageUrl: 'https://images.unsplash.com/photo-1509423350716-97f9360b4e09?w=600&auto=format&fit=crop&q=80',
      sellerName: 'Flora Asri Sentosa',
      sellerLocation: 'Tebet, Jakarta Selatan',
      sellerLat: -6.2297,
      sellerLng: 106.8580,
      rating: 4.8,
    ),
    ProductModel(
      id: 'p7',
      name: 'Aglaonema Suksom Merah',
      categoryId: 'tanaman_hias',
      description: 'Pesona daun merah menyala aglaonema import. Tampil mewah elegan di meja kerja atau teras.',
      price: 85000,
      unit: 'pot',
      stock: 8,
      imageUrl: 'https://images.unsplash.com/photo-1597055181300-e3633a917c9c?w=600&auto=format&fit=crop&q=80',
      sellerName: 'Kebun Hijau Ciganjur',
      sellerLocation: 'Jagakarsa, Jakarta Selatan',
      sellerLat: -6.3401,
      sellerLng: 106.8095,
      rating: 4.9,
    ),
    ProductModel(
      id: 'p8',
      name: 'Pisang Cavendish Manis',
      categoryId: 'buah',
      description: 'Pisang matang pohon kulit mulus kuning cerah rasa legit manis. Bebas karbit kimiawi.',
      price: 24000,
      unit: 'kg',
      stock: 40,
      imageUrl: 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=600&auto=format&fit=crop&q=80',
      sellerName: 'Buah Segar Nusantara',
      sellerLocation: 'Kebayoran Baru, Jakarta Selatan',
      sellerLat: -6.2444,
      sellerLng: 106.7972,
      rating: 4.8,
    ),
    ProductModel(
      id: 'p9',
      name: 'Apel Fuji Manis Renyah',
      categoryId: 'buah',
      description: 'Apel merah kaya air bertekstur garing manis menyegarkan, pas untuk asupan vitamin harian keluarga.',
      price: 38000,
      unit: 'kg',
      stock: 28,
      imageUrl: 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=600&auto=format&fit=crop&q=80',
      sellerName: 'Buah Segar Nusantara',
      sellerLocation: 'Kebayoran Baru, Jakarta Selatan',
      sellerLat: -6.2444,
      sellerLng: 106.7972,
      rating: 4.9,
    ),
    ProductModel(
      id: 'p10',
      name: 'Jeruk Medan Manis Segar',
      categoryId: 'buah',
      description: 'Jeruk peras atau kupas berkulit tipis air melimpah manis alami tanpa rasa asam getir.',
      price: 28000,
      unit: 'kg',
      stock: 50,
      imageUrl: 'https://images.unsplash.com/photo-1611080626919-7cf5a9dbab5b?w=600&auto=format&fit=crop&q=80',
      sellerName: 'Buah Segar Nusantara',
      sellerLocation: 'Kebayoran Baru, Jakarta Selatan',
      sellerLat: -6.2444,
      sellerLng: 106.7972,
      rating: 4.7,
    ),
    ProductModel(
      id: 'p11',
      name: 'Ketapang Biola (Fiddle Leaf)',
      categoryId: 'tanaman_hias',
      description: 'Ficus Lyrata berdaun lebar mengkilap seperti biola. Sangat populer untuk estetika interior minimalis.',
      price: 115000,
      unit: 'pot',
      stock: 15,
      imageUrl: 'https://images.unsplash.com/photo-1599598425947-63098d697f3d?w=600&auto=format&fit=crop&q=80',
      sellerName: 'Flora Asri Sentosa',
      sellerLocation: 'Tebet, Jakarta Selatan',
      sellerLat: -6.2297,
      sellerLng: 106.8580,
      rating: 4.9,
    ),
    ProductModel(
      id: 'p12',
      name: 'Tomat Cherry Hidroponik',
      categoryId: 'sayuran',
      description: 'Tomat cherry merah manis segar dipetik pohon, kaya antioksidan likopen dan vitamin C.',
      price: 15000,
      unit: 'pack',
      stock: 30,
      imageUrl: 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=600&auto=format&fit=crop&q=80',
      sellerName: 'Hydro Fresh Garden',
      sellerLocation: 'Jagakarsa, Jakarta Selatan',
      sellerLat: -6.3312,
      sellerLng: 106.8288,
      rating: 4.8,
    ),
    ProductModel(
      id: 'p13',
      name: 'Alpukat Mentega Super',
      categoryId: 'buah',
      description: 'Alpukat berdaging tebal kuning mentega legit tanpa serat kasar. Sangat cocok untuk jus atau salad sehat.',
      price: 35000,
      unit: 'kg',
      stock: 25,
      imageUrl: 'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?w=600&auto=format&fit=crop&q=80',
      sellerName: 'Buah Segar Nusantara',
      sellerLocation: 'Kebayoran Baru, Jakarta Selatan',
      sellerLat: -6.2444,
      sellerLng: 106.7972,
      rating: 4.9,
    ),
    ProductModel(
      id: 'p14',
      name: 'Selada Romaine Segar',
      categoryId: 'sayuran',
      description: 'Selada romaine renyah segar hidroponik bebas pestisida. Tekstur daun garing cocok untuk salad sehat.',
      price: 9500,
      unit: 'ikat',
      stock: 35,
      imageUrl: 'https://images.unsplash.com/photo-1622206151226-18ca2c9ab4a1?w=600&auto=format&fit=crop&q=80',
      sellerName: 'Sayur Lembang Lestari',
      sellerLocation: 'Cilandak, Jakarta Selatan',
      sellerLat: -6.2952,
      sellerLng: 106.8041,
      rating: 4.7,
    ),
    ProductModel(
      id: 'p15',
      name: 'Philodendron Birkin',
      categoryId: 'tanaman_hias',
      description: 'Tanaman hias cantik dengan corak garis putih artistik pada daun hijau pekat. Mudah dirawat di dalam ruangan.',
      price: 65000,
      unit: 'pot',
      stock: 18,
      imageUrl: 'https://images.unsplash.com/photo-1616690710400-a16d146927c5?w=600&auto=format&fit=crop&q=80',
      sellerName: 'Kebun Hijau Ciganjur',
      sellerLocation: 'Jagakarsa, Jakarta Selatan',
      sellerLat: -6.3401,
      sellerLng: 106.8095,
      rating: 4.8,
    ),
    ProductModel(
      id: 'p16',
      name: 'Cabai Rawit Merah Segar',
      categoryId: 'sayuran',
      description: 'Cabai rawit merah segar pedas menggigit, langsung dipanen dari perkebunan dataran tinggi.',
      price: 12000,
      unit: '250gr',
      stock: 50,
      imageUrl: 'https://images.unsplash.com/photo-1588252303782-cb80119abd6d?w=600&auto=format&fit=crop&q=80',
      sellerName: 'Kebun Tani Makmur',
      sellerLocation: 'Pasar Minggu, Jakarta Selatan',
      sellerLat: -6.2847,
      sellerLng: 106.8441,
      rating: 4.9,
    ),
    ProductModel(
      id: 'p17',
      name: 'Mangga Harum Manis Matang',
      categoryId: 'buah',
      description: 'Mangga harum manis matang pohon berkualitas premium. Daging buah lembut manis berserat halus.',
      price: 28000,
      unit: 'kg',
      stock: 30,
      imageUrl: 'https://images.unsplash.com/photo-1553279768-865429fa0078?w=600&auto=format&fit=crop&q=80',
      sellerName: 'Buah Segar Nusantara',
      sellerLocation: 'Kebayoran Baru, Jakarta Selatan',
      sellerLat: -6.2444,
      sellerLng: 106.7972,
      rating: 4.8,
    ),
    ProductModel(
      id: 'p18',
      name: 'Janda Bolong (Adansonii)',
      categoryId: 'tanaman_hias',
      description: 'Monstera Adansonii dengan lubang khas alami pada daun. Sangat cocok untuk pot gantung atau tanaman meja.',
      price: 35000,
      unit: 'pot',
      stock: 22,
      imageUrl: 'https://images.unsplash.com/photo-1614594975525-e45190c55d0b?w=600&auto=format&fit=crop&q=80',
      sellerName: 'Flora Asri Sentosa',
      sellerLocation: 'Tebet, Jakarta Selatan',
      sellerLat: -6.2297,
      sellerLng: 106.8580,
      rating: 4.7,
    ),
    ProductModel(
      id: 'p19',
      name: 'Stroberi Ciwidey Segar',
      categoryId: 'buah',
      description: 'Stroberi merah segar dari kebun Ciwidey Bandung. Manis segar dengan aroma khas alami pegunungan.',
      price: 22000,
      unit: 'pack',
      stock: 20,
      imageUrl: 'https://images.unsplash.com/photo-1464965911861-746a04b4bca6?w=600&auto=format&fit=crop&q=80',
      sellerName: 'Buah Segar Nusantara',
      sellerLocation: 'Kebayoran Baru, Jakarta Selatan',
      sellerLat: -6.2444,
      sellerLng: 106.7972,
      rating: 4.9,
    ),
    ProductModel(
      id: 'p20',
      name: 'Kaktus Sukulen Mix Mini',
      categoryId: 'tanaman_hias',
      description: 'Koleksi aneka sukulen mini lucu dalam pot keramik. Tidak membutuhkan perawatan rumit dan hemat air.',
      price: 25000,
      unit: 'pot',
      stock: 40,
      imageUrl: 'https://images.unsplash.com/photo-1459411552884-841db9b3cc2a?w=600&auto=format&fit=crop&q=80',
      sellerName: 'Kebun Hijau Ciganjur',
      sellerLocation: 'Jagakarsa, Jakarta Selatan',
      sellerLat: -6.3401,
      sellerLng: 106.8095,
      rating: 4.8,
    ),
    ProductModel(
      id: 'p21',
      name: 'Jamur Tiram Putih Segar',
      categoryId: 'sayuran',
      description: 'Jamur tiram putih organik bertekstur empuk kenyal, lezat untuk tumis atau jamur krispi renyah.',
      price: 8500,
      unit: 'pack',
      stock: 30,
      imageUrl: 'https://images.unsplash.com/photo-1504544750208-dc0358e63f7f?w=600&auto=format&fit=crop&q=80',
      sellerName: 'Kebun Tani Makmur',
      sellerLocation: 'Pasar Minggu, Jakarta Selatan',
      sellerLat: -6.2847,
      sellerLng: 106.8441,
      rating: 4.6,
    ),
    ProductModel(
      id: 'p22',
      name: 'Sirih Gading (Golden Pothos)',
      categoryId: 'tanaman_hias',
      description: 'Tanaman rambat daun bercorak kuning emas pembersih udara ampuh, sangat toleran di ruangan indoor.',
      price: 30000,
      unit: 'pot',
      stock: 28,
      imageUrl: 'https://images.unsplash.com/photo-1509423350716-97f9360b4e09?w=600&auto=format&fit=crop&q=80',
      sellerName: 'Flora Asri Sentosa',
      sellerLocation: 'Tebet, Jakarta Selatan',
      sellerLat: -6.2297,
      sellerLng: 106.8580,
      rating: 4.9,
    ),
    ProductModel(
      id: 'p23',
      name: 'Buah Naga Merah Manis',
      categoryId: 'buah',
      description: 'Buah naga daging merah manis tinggi antioksidan dan serat, dipetik segar saat kematangan optimal.',
      price: 19000,
      unit: 'kg',
      stock: 25,
      imageUrl: 'https://images.unsplash.com/photo-1527325678964-54921661f888?w=600&auto=format&fit=crop&q=80',
      sellerName: 'Buah Segar Nusantara',
      sellerLocation: 'Kebayoran Baru, Jakarta Selatan',
      sellerLat: -6.2444,
      sellerLng: 106.7972,
      rating: 4.7,
    ),
    ProductModel(
      id: 'p24',
      name: 'Paprika Merah Segar',
      categoryId: 'sayuran',
      description: 'Paprika merah manis renyah dengan warna merah berkilau, kaya vitamin A dan C untuk hidangan istimewa.',
      price: 21000,
      unit: '500gr',
      stock: 18,
      imageUrl: 'https://images.unsplash.com/photo-1563565375-f3fdfdbefa83?w=600&auto=format&fit=crop&q=80',
      sellerName: 'Sayur Lembang Lestari',
      sellerLocation: 'Cilandak, Jakarta Selatan',
      sellerLat: -6.2952,
      sellerLng: 106.8041,
      rating: 4.8,
    ),
  ];

  static final List<UserModel> _mockUsers = [
    UserModel(
      id: 'user_1',
      name: 'Sari Lestari',
      email: 'sari@example.com',
      username: 'sari_lestari',
      passwordHash: 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', // password123
      phone: '081234567890',
      photoUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&auto=format&fit=crop&q=80',
    ),
  ];

  static final List<OrderModel> _mockOrders = [];

  Future<void> _checkSimulatedError() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (simulateNetworkError) {
      throw const SocketException('Tidak dapat terhubung ke server (Simulasi Mode Offline)');
    }
  }

  Future<List<CategoryModel>> getCategories() async {
    await _checkSimulatedError();
    return List<CategoryModel>.from(_mockCategories);
  }

  Future<List<ProductModel>> getProducts({String? category, String? q}) async {
    await _checkSimulatedError();
    List<ProductModel> list = List<ProductModel>.from(_mockProducts);

    if (category != null && category.isNotEmpty && category != 'semua') {
      list = list.where((p) => p.categoryId.toLowerCase() == category.toLowerCase()).toList();
    }

    if (q != null && q.trim().isNotEmpty) {
      final query = q.toLowerCase().trim();
      list = list.where((p) => p.name.toLowerCase().contains(query) || p.description.toLowerCase().contains(query)).toList();
    }

    return list;
  }

  Future<ProductModel> getProductById(String id) async {
    await _checkSimulatedError();
    return _mockProducts.firstWhere(
      (p) => p.id == id,
      orElse: () => throw HttpException('Produk dengan ID $id tidak ditemukan'),
    );
  }

  Future<UserModel> registerUser(Map<String, dynamic> userData) async {
    await _checkSimulatedError();
    final email = userData['email']?.toString().toLowerCase().trim() ?? '';
    final username = userData['username']?.toString().trim() ?? '';

    final exists = _mockUsers.any((u) => u.email.toLowerCase() == email || u.username.toLowerCase() == username.toLowerCase());
    if (exists) {
      throw const HttpException('Email atau Username sudah terdaftar');
    }

    final newUser = UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: userData['name']?.toString() ?? 'Pengguna Wiji Bumi',
      email: email,
      username: username,
      passwordHash: userData['passwordHash']?.toString() ?? '',
      phone: userData['phone']?.toString() ?? '',
      photoUrl: userData['photoUrl']?.toString() ?? '',
    );

    _mockUsers.add(newUser);
    return newUser;
  }

  Future<UserModel> loginUser(String identifier, String passwordHash) async {
    await _checkSimulatedError();
    final cleanId = identifier.toLowerCase().trim();
    try {
      return _mockUsers.firstWhere(
        (u) => (u.email.toLowerCase() == cleanId || u.username.toLowerCase() == cleanId) && u.passwordHash == passwordHash,
      );
    } catch (_) {
      throw const HttpException('Email/Username atau password salah');
    }
  }

  Future<UserModel> updateUser(String userId, Map<String, dynamic> updateData) async {
    await _checkSimulatedError();
    final index = _mockUsers.indexWhere((u) => u.id == userId);
    if (index == -1) {
      throw const HttpException('User tidak ditemukan');
    }

    final oldUser = _mockUsers[index];
    final updatedUser = oldUser.copyWith(
      name: updateData['name']?.toString() ?? oldUser.name,
      phone: updateData['phone']?.toString() ?? oldUser.phone,
      photoUrl: updateData['photoUrl']?.toString() ?? oldUser.photoUrl,
    );

    _mockUsers[index] = updatedUser;
    return updatedUser;
  }

  Future<OrderModel> createOrder(Map<String, dynamic> orderData) async {
    await _checkSimulatedError();
    final newOrder = OrderModel.fromJson(orderData);

    // Validasi stok produk
    for (var item in newOrder.items) {
      final productIndex = _mockProducts.indexWhere((p) => p.id == item.productId);
      if (productIndex != -1) {
        final currentStock = _mockProducts[productIndex].stock;
        if (currentStock < item.quantity) {
          throw HttpException('Stok untuk produk "${item.name}" tidak mencukupi (sisa $currentStock)');
        }
      }
    }

    // Kurangi stok produk
    for (var item in newOrder.items) {
      final productIndex = _mockProducts.indexWhere((p) => p.id == item.productId);
      if (productIndex != -1) {
        final current = _mockProducts[productIndex];
        _mockProducts[productIndex] = current.copyWith(stock: current.stock - item.quantity);
      }
    }

    _mockOrders.insert(0, newOrder);
    return newOrder;
  }

  Future<List<OrderModel>> getOrders(String userId) async {
    await _checkSimulatedError();
    return _mockOrders.where((o) => o.userId == userId).toList();
  }

  Future<OrderModel> getOrderById(String id) async {
    await _checkSimulatedError();
    return _mockOrders.firstWhere(
      (o) => o.id == id,
      orElse: () => throw HttpException('Pesanan dengan ID $id tidak ditemukan'),
    );
  }

  Future<OrderModel> updateOrderStatus(String id, String newStatus) async {
    await _checkSimulatedError();
    final index = _mockOrders.indexWhere((o) => o.id == id);
    if (index == -1) {
      throw const HttpException('Pesanan tidak ditemukan');
    }

    final old = _mockOrders[index];
    final updated = old.copyWith(status: newStatus);
    _mockOrders[index] = updated;
    return updated;
  }
}

/// ============================================================================
/// 3. WRAPPER REPOSITORY UNTUK KOMPATIBILITAS (SEPERTI PADA TEST & SERVICE)
/// ============================================================================

class AuthRepository {
  final ApiService apiService;
  final PrefService prefService;

  AuthRepository({required this.apiService, required this.prefService});

  String hashPassword(String password) => ApiService.hashPassword(password);

  Future<UserModel> register({
    required String name,
    required String email,
    required String username,
    required String password,
    String? phone,
  }) async {
    final passwordHash = hashPassword(password);
    return await apiService.registerUser({
      'name': name,
      'email': email,
      'username': username,
      'passwordHash': passwordHash,
      'phone': phone ?? '',
    });
  }

  Future<UserModel> login({required String identifier, required String password}) async {
    final passwordHash = hashPassword(password);
    final user = await apiService.loginUser(identifier, passwordHash);
    await prefService.saveSession(
      userId: user.id,
      token: 'session_token_${DateTime.now().millisecondsSinceEpoch}',
    );
    return user;
  }

  Future<UserModel> updateProfile({required String userId, String? name, String? phone, String? photoUrl}) async {
    return await apiService.updateUser(userId, {
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (photoUrl != null) 'photoUrl': photoUrl,
    });
  }

  Future<void> logout() async => await prefService.clearSession();
  bool get isLoggedIn => prefService.isLoggedIn;
  String get currentUserId => prefService.userId;
}

class ProductRepository {
  final ApiService apiService;
  ProductRepository({required this.apiService});

  Future<List<CategoryModel>> getCategories() => apiService.getCategories();
  Future<List<ProductModel>> getProducts({String? category, String? q}) => apiService.getProducts(category: category, q: q);
  Future<ProductModel> getProductById(String id) => apiService.getProductById(id);
}

class OrderRepository {
  final ApiService apiService;
  OrderRepository({required this.apiService});

  static String generateOrderNumber() => ApiService.generateOrderNumber();

  Future<OrderModel> placeOrder({
    required String userId,
    required AddressModel address,
    required List<CartItemModel> items,
    required String paymentMethod,
    required double shippingCost,
  }) async {
    final subtotal = items.fold(0.0, (sum, item) => sum + item.subtotal);
    final total = subtotal + shippingCost;
    final orderNumber = generateOrderNumber();
    final initialStatus = (paymentMethod.toUpperCase() == 'COD') ? 'Diproses' : 'Menunggu Pembayaran';

    final orderItems = items.map((item) => OrderItemModel(
      productId: item.productId,
      name: item.name,
      price: item.price,
      unit: item.unit,
      quantity: item.quantity,
      subtotal: item.subtotal,
    )).toList();

    final orderData = {
      'id': 'ord_${DateTime.now().millisecondsSinceEpoch}',
      'orderNumber': orderNumber,
      'userId': userId,
      'createdAt': DateTime.now().toIso8601String(),
      'status': initialStatus,
      'paymentMethod': paymentMethod,
      'address': address.toJson(),
      'subtotal': subtotal,
      'shippingCost': shippingCost,
      'total': total,
      'items': orderItems.map((i) => i.toJson()).toList(),
    };

    return await apiService.createOrder(orderData);
  }

  Future<List<OrderModel>> getOrders(String userId) => apiService.getOrders(userId);
  Future<OrderModel> getOrderById(String id) => apiService.getOrderById(id);
  Future<OrderModel> updateStatus(String id, String status) => apiService.updateOrderStatus(id, status);
}
