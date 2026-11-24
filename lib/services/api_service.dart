import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import 'database_helper.dart';

/// ============================================================================
/// 1. PREF SERVICE (PENYIMPANAN SESI & PREFERENSI VIA SHAREDPREFERENCES)
/// ============================================================================
class PrefService {
  static const String prefIsLoggedIn = 'is_logged_in';
  static const String prefUserId = 'user_id';
  static const String prefSessionToken = 'session_token';
  static const String prefThemeMode = 'theme_mode';
  static const String prefNotifEnabled = 'notif_enabled';
  static const String prefSelectedStoreId = 'selected_store_id';

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

  String get selectedStoreId => _prefs.getString(prefSelectedStoreId) ?? 'sleman';
  Future<void> setSelectedStoreId(String storeId) async => await _prefs.setString(prefSelectedStoreId, storeId);
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
  static List<ProductModel>? _csvProducts;
  static List<CategoryModel>? _csvCategories;
  static bool _hasLoadedCsv = false;

  /// Memuat katalog produk dan kategori dari file CSV lokal
  static Future<void> loadCatalogFromCsv({String path = 'assets/data/Katalog_WijiBumi.csv'}) async {
    if (_hasLoadedCsv && _csvProducts != null && _csvProducts!.isNotEmpty) return;
    try {
      final list = await ProductModel.loadFromAssets(path: path);
      if (list.isNotEmpty) {
        _csvProducts = list;
        _csvCategories = CategoryModel.fromProductList(list);
        _hasLoadedCsv = true;
      }
    } catch (_) {
      // Fallback jika tidak dalam lingkungan asset bundle Flutter
      _csvProducts ??= List<ProductModel>.from(_mockProducts);
      _csvCategories ??= List<CategoryModel>.from(_mockCategories);
      _hasLoadedCsv = true;
    }
  }

  static List<ProductModel> get currentProducts => _csvProducts ?? _mockProducts;
  static List<CategoryModel> get currentCategories => _csvCategories ?? _mockCategories;

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
      imageUrl: 'assets/images/products/veg_bayam.jpg',
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
      imageUrl: 'assets/images/products/veg_kangkung.jpg',
      sellerName: 'Hydro Fresh Garden',
      sellerLocation: 'Jagakarsa, Jakarta Selatan',
      sellerLat: -6.3312,
      sellerLng: 106.8288,
      rating: 4.8,
    ),
    ProductModel(
      id: 'p5',
      name: 'Monstera Deliciosa Dewasa',
      categoryId: 'tanaman_hias',
      description: 'Tanaman hias tropis daun sobek ikonik, cocok mempercantik sudut ruangan dan pembersih udara.',
      price: 125000,
      unit: 'pot',
      stock: 12,
      imageUrl: 'assets/images/products/FLW001.jpg',
      sellerName: 'Flora Asri Sentosa',
      sellerLocation: 'Tebet, Jakarta Selatan',
      sellerLat: -6.2297,
      sellerLng: 106.8580,
      rating: 5.0,
    ),
    ProductModel(
      id: 'p8',
      name: 'Pisang Cavendish Manis',
      categoryId: 'buah',
      description: 'Pisang matang pohon kulit mulus kuning cerah rasa legit manis. Bebas karbit kimiawi.',
      price: 24000,
      unit: 'kg',
      stock: 40,
      imageUrl: 'assets/images/products/FRU001.jpg',
      sellerName: 'Buah Segar Nusantara',
      sellerLocation: 'Kebayoran Baru, Jakarta Selatan',
      sellerLat: -6.2444,
      sellerLng: 106.7972,
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
    if (!_hasLoadedCsv) {
      await loadCatalogFromCsv();
    }
    return List<CategoryModel>.from(currentCategories);
  }

  Future<List<ProductModel>> getProducts({String? category, String? q}) async {
    await _checkSimulatedError();
    if (!_hasLoadedCsv) {
      await loadCatalogFromCsv();
    }
    List<ProductModel> list = List<ProductModel>.from(currentProducts);

    if (category != null && category.isNotEmpty && category != 'semua') {
      final sel = category.toLowerCase().trim();
      list = list.where((p) {
        final catP = p.categoryId.toLowerCase().trim();
        if (catP == sel) return true;
        if ((catP == 'sayur' || catP == 'sayuran') && (sel == 'sayur' || sel == 'sayuran')) return true;
        if ((catP == 'bunga' || catP == 'tanaman_hias') && (sel == 'bunga' || sel == 'tanaman_hias')) return true;
        return false;
      }).toList();
    }

    if (q != null && q.trim().isNotEmpty) {
      final query = q.toLowerCase().trim();
      list = list.where((p) =>
        p.name.toLowerCase().contains(query) ||
        p.description.toLowerCase().contains(query) ||
        p.origin.toLowerCase().contains(query)
      ).toList();
    }

    return list;
  }

  Future<ProductModel> getProductById(String id) async {
    await _checkSimulatedError();
    if (!_hasLoadedCsv) {
      await loadCatalogFromCsv();
    }
    final allProducts = currentProducts;
    return allProducts.firstWhere(
      (p) => p.id == id,
      orElse: () => _mockProducts.firstWhere(
        (p) => p.id == id,
        orElse: () => throw HttpException('Produk dengan ID $id tidak ditemukan'),
      ),
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
      // Periksa apakah user terdaftar di database SQLite lokal
      try {
        final dbUser = await DatabaseHelper.getUserByEmailOrUsername(cleanId);
        if (dbUser != null) {
          final storedHash = dbUser['password_hash'] as String? ?? '';
          final storedPass = dbUser['password'] as String? ?? '';
          if (storedHash == passwordHash || hashPassword(storedPass) == passwordHash) {
            final u = UserModel(
              id: dbUser['id'] as String? ?? '',
              name: dbUser['name'] as String? ?? '',
              email: dbUser['email'] as String? ?? '',
              username: dbUser['username'] as String? ?? '',
              passwordHash: storedHash.isNotEmpty ? storedHash : passwordHash,
              phone: dbUser['phone'] as String? ?? '',
              photoUrl: dbUser['photo_url'] as String? ?? '',
              createdAt: dbUser['created_at'] as String? ?? '',
            );
            _mockUsers.add(u);
            return u;
          }
        }
      } catch (_) {}
      throw const HttpException('Email/Username atau password salah');
    }
  }

  Future<UserModel> updateUser(String userId, Map<String, dynamic> updateData) async {
    await _checkSimulatedError();
    final index = _mockUsers.indexWhere((u) => u.id == userId);
    if (index == -1) {
      final local = await DatabaseHelper.getUserById(userId);
      if (local != null) {
        final u = UserModel(
          id: local['id']?.toString() ?? userId,
          name: updateData['name']?.toString() ?? local['name']?.toString() ?? '',
          email: local['email']?.toString() ?? '',
          username: local['username']?.toString() ?? '',
          passwordHash: updateData['passwordHash']?.toString() ?? local['password_hash']?.toString() ?? '',
          phone: updateData['phone']?.toString() ?? local['phone']?.toString() ?? '',
          photoUrl: updateData['photoUrl']?.toString() ?? local['photo_url']?.toString() ?? '',
        );
        _mockUsers.add(u);
        return u;
      }
      throw const HttpException('User tidak ditemukan');
    }

    final oldUser = _mockUsers[index];
    final updatedUser = oldUser.copyWith(
      name: updateData['name']?.toString() ?? oldUser.name,
      phone: updateData['phone']?.toString() ?? oldUser.phone,
      photoUrl: updateData['photoUrl']?.toString() ?? oldUser.photoUrl,
      passwordHash: updateData['passwordHash']?.toString() ?? oldUser.passwordHash,
    );

    _mockUsers[index] = updatedUser;
    return updatedUser;
  }

  Future<OrderModel> createOrder(Map<String, dynamic> orderData) async {
    await _checkSimulatedError();
    final newOrder = OrderModel.fromJson(orderData);
    final targetList = _csvProducts ?? _mockProducts;

    // Validasi stok produk
    for (var item in newOrder.items) {
      final productIndex = targetList.indexWhere((p) => p.id == item.productId);
      if (productIndex != -1) {
        final currentStock = targetList[productIndex].stock;
        if (currentStock < item.quantity) {
          throw HttpException('Stok untuk produk "${item.name}" tidak mencukupi (sisa $currentStock)');
        }
      }
    }

    // Kurangi stok produk
    for (var item in newOrder.items) {
      final productIndex = targetList.indexWhere((p) => p.id == item.productId);
      if (productIndex != -1) {
        final current = targetList[productIndex];
        targetList[productIndex] = current.copyWith(stock: current.stock - item.quantity);
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

  Future<OrderModel> updateOrderPaymentMethod(String id, String newPaymentMethod) async {
    await _checkSimulatedError();
    final index = _mockOrders.indexWhere((o) => o.id == id);
    if (index == -1) {
      throw const HttpException('Pesanan tidak ditemukan');
    }

    final old = _mockOrders[index];
    final updated = old.copyWith(paymentMethod: newPaymentMethod);
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
    final user = await apiService.registerUser({
      'name': name,
      'email': email,
      'username': username,
      'passwordHash': passwordHash,
      'phone': phone ?? '',
    });
    try {
      await DatabaseHelper.saveUser(
        id: user.id,
        name: user.name,
        email: user.email,
        username: user.username,
        phone: user.phone,
        password: password,
        passwordHash: passwordHash,
        photoUrl: user.photoUrl,
        createdAt: user.createdAt,
      );
    } catch (_) {}
    return user;
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

  Future<UserModel> updateProfile({
    required String userId,
    String? name,
    String? phone,
    String? photoUrl,
    String? passwordHash,
  }) async {
    return await apiService.updateUser(userId, {
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (passwordHash != null) 'passwordHash': passwordHash,
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

    final createdOrder = await apiService.createOrder(orderData);
    try {
      await DatabaseHelper.saveOrder(createdOrder);
    } catch (_) {}
    return createdOrder;
  }

  Future<List<OrderModel>> getOrders(String userId) => apiService.getOrders(userId);
  Future<OrderModel> getOrderById(String id) => apiService.getOrderById(id);
  Future<OrderModel> updateStatus(String id, String status) => apiService.updateOrderStatus(id, status);
  Future<OrderModel> updatePaymentMethod(String id, String paymentMethod) => apiService.updateOrderPaymentMethod(id, paymentMethod);
}
