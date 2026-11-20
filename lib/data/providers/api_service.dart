import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';

class ApiService {
  final http.Client client;
  final String baseUrl;
  static const Duration timeoutDuration = Duration(seconds: 15);

  // Toggle simulasi kegagalan jaringan untuk keperluan pengujian dan video praktikum (TC-08, TC-15)
  static bool simulateNetworkError = false;

  ApiService({
    http.Client? client,
    this.baseUrl = 'https://api.wijibumi.local/v1',
  }) : client = client ?? http.Client();

  // In-Memory Mock Database
  static final List<CategoryModel> _mockCategories = [
    CategoryModel(id: 'tanaman_hias', name: 'Big plants', icon: 'yard'),
    CategoryModel(id: 'sayuran', name: 'Outdoor', icon: 'grass'),
    CategoryModel(id: 'buah', name: 'Indoor', icon: 'apple'),
  ];

  static final List<ProductModel> _mockProducts = [
    // Sayuran
    ProductModel(
      id: 'p1',
      name: 'Bayam Hijau Organik',
      categoryId: 'sayuran',
      description:
          'Bayam segar langsung dari kebun organik tanpa pestisida kimia. Kaya akan zat besi dan vitamin A.',
      price: 6500,
      unit: 'ikat',
      stock: 45,
      imageUrl:
          'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=600&auto=format&fit=crop&q=80',
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
      description:
          'Kangkung renyah dibudidayakan secara hidroponik bersih, segar, dan siap masak untuk tumis lezat.',
      price: 5000,
      unit: 'ikat',
      stock: 30,
      imageUrl:
          'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=600&auto=format&fit=crop&q=80',
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
      description:
          'Brokoli hijau padat bebas ulat dengan kuntum segar berkualitas ekspor. Baik untuk daya tahan tubuh.',
      price: 18000,
      unit: 'kg',
      stock: 20,
      imageUrl:
          'https://images.unsplash.com/photo-1584270354949-c26b0d5b4a0c?w=600&auto=format&fit=crop&q=80',
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
      description:
          'Wortel renyah manis asal Brastagi, kaya beta karoten untuk kesehatan mata dan jus segar.',
      price: 14000,
      unit: 'kg',
      stock: 35,
      imageUrl:
          'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=600&auto=format&fit=crop&q=80',
      sellerName: 'Kebun Tani Makmur',
      sellerLocation: 'Pasar Minggu, Jakarta Selatan',
      sellerLat: -6.2847,
      sellerLng: 106.8441,
      rating: 4.7,
    ),
    ProductModel(
      id: 'p5',
      name: 'Tomat Ceri Merah Manis',
      categoryId: 'sayuran',
      description:
          'Tomat ceri merah berkilau dengan rasa manis segar, cocok untuk campuran salad atau camilan sehat.',
      price: 16000,
      unit: 'gram',
      stock: 15,
      imageUrl:
          'https://images.unsplash.com/photo-1546470427-e26264be0b11?w=600&auto=format&fit=crop&q=80',
      sellerName: 'Hydro Fresh Garden',
      sellerLocation: 'Jagakarsa, Jakarta Selatan',
      sellerLat: -6.3312,
      sellerLng: 106.8288,
      rating: 4.8,
    ),
    ProductModel(
      id: 'p6',
      name: 'Cabai Rawit Merah Pedas Alami',
      categoryId: 'sayuran',
      description:
          'Cabai rawit merah petik langsung dari petani lokal, pedas menggigit dan tahan disimpan lama.',
      price: 25000,
      unit: 'kg',
      stock: 0, // Contoh produk stok habis untuk menguji FR-CART-08
      imageUrl:
          'https://images.unsplash.com/photo-1588252303782-cb80119abd6d?w=600&auto=format&fit=crop&q=80',
      sellerName: 'Kebun Tani Makmur',
      sellerLocation: 'Pasar Minggu, Jakarta Selatan',
      sellerLat: -6.2847,
      sellerLng: 106.8441,
      rating: 4.6,
    ),

    // Buah-buahan
    ProductModel(
      id: 'p7',
      name: 'Pisang Cavendish Sunpride',
      categoryId: 'buah',
      description:
          'Pisang cavendish matang alami, kulit bersih mulus rasa manis legit sumber energi praktis harian.',
      price: 22000,
      unit: 'kg',
      stock: 50,
      imageUrl:
          'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=600&auto=format&fit=crop&q=80',
      sellerName: 'Toko Buah Segar Sejahtera',
      sellerLocation: 'Tebet, Jakarta Selatan',
      sellerLat: -6.2300,
      sellerLng: 106.8500,
      rating: 4.9,
    ),
    ProductModel(
      id: 'p8',
      name: 'Apel Malang Manalagi Renyah',
      categoryId: 'buah',
      description:
          'Apel malang hijau kekuningan beraroma wangi khas dan rasa manis segar renyah tiada duanya.',
      price: 28000,
      unit: 'kg',
      stock: 25,
      imageUrl:
          'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=600&auto=format&fit=crop&q=80',
      sellerName: 'Toko Buah Segar Sejahtera',
      sellerLocation: 'Tebet, Jakarta Selatan',
      sellerLat: -6.2300,
      sellerLng: 106.8500,
      rating: 4.8,
    ),
    ProductModel(
      id: 'p9',
      name: 'Jeruk Medan Manis Super',
      categoryId: 'buah',
      description:
          'Jeruk medan dengan bulir penuh air melimpah, manis segar alami untuk asupan vitamin C keluarga.',
      price: 24000,
      unit: 'kg',
      stock: 40,
      imageUrl:
          'https://images.unsplash.com/photo-1611080626919-7cf5a9dbab5b?w=600&auto=format&fit=crop&q=80',
      sellerName: 'Toko Buah Segar Sejahtera',
      sellerLocation: 'Tebet, Jakarta Selatan',
      sellerLat: -6.2300,
      sellerLng: 106.8500,
      rating: 4.7,
    ),
    ProductModel(
      id: 'p10',
      name: 'Alpukat Mentega Super Pulen',
      categoryId: 'buah',
      description:
          'Alpukat mentega daging tebal tekstur lembut seperti mentega tanpa serat pahit. Garansi matang sempurna.',
      price: 35000,
      unit: 'kg',
      stock: 18,
      imageUrl:
          'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?w=600&auto=format&fit=crop&q=80',
      sellerName: 'Kebun Wiji Bumi Pusat',
      sellerLocation: 'Mampang Prapatan, Jakarta Selatan',
      sellerLat: -6.2520,
      sellerLng: 106.8290,
      rating: 5.0,
    ),

    // Bunga & Tanaman Hias
    ProductModel(
      id: 'p11',
      name: 'Monstera Deliciosa Dewasa',
      categoryId: 'tanaman_hias',
      description:
          'Tanaman hias ikonik dengan daun berlubang khas eksotis. Termasuk pot terakota minimalis.',
      price: 85000,
      unit: 'pot',
      stock: 12,
      imageUrl:
          'https://images.unsplash.com/photo-1614594975525-e45190c55d0b?w=600&auto=format&fit=crop&q=80',
      sellerName: 'Flora Asri Nusantara',
      sellerLocation: 'Kebayoran Baru, Jakarta Selatan',
      sellerLat: -6.2440,
      sellerLng: 106.7980,
      rating: 4.9,
    ),
    ProductModel(
      id: 'p12',
      name: 'Aglaonema Suksom Jaipong Merah',
      categoryId: 'tanaman_hias',
      description:
          'Aglaonema dengan warna merah menyala spektakuler. Tanaman pembersih udara yang mudah dirawat di dalam ruangan.',
      price: 65000,
      unit: 'pot',
      stock: 8,
      imageUrl:
          'https://images.unsplash.com/photo-1598880940371-c756e015fea1?w=600&auto=format&fit=crop&q=80',
      sellerName: 'Flora Asri Nusantara',
      sellerLocation: 'Kebayoran Baru, Jakarta Selatan',
      sellerLat: -6.2440,
      sellerLng: 106.7980,
      rating: 4.8,
    ),
    ProductModel(
      id: 'p13',
      name: 'Lidah Mertua (Sansevieria Trifasciata)',
      categoryId: 'tanaman_hias',
      description:
          'Tanaman tangguh penyerap racun udara ruangan. Tahan banting dan hanya butuh sedikit air setiap minggunya.',
      price: 35000,
      unit: 'pot',
      stock: 22,
      imageUrl:
          'https://images.unsplash.com/photo-1593482892290-f54927ae1bd6?w=600&auto=format&fit=crop&q=80',
      sellerName: 'Flora Asri Nusantara',
      sellerLocation: 'Kebayoran Baru, Jakarta Selatan',
      sellerLat: -6.2440,
      sellerLng: 106.7980,
      rating: 4.8,
    ),
    ProductModel(
      id: 'p14',
      name: 'Kaktus Mini Sukulen Keramik',
      categoryId: 'tanaman_hias',
      description:
          'Set kaktus mini sukulen dalam pot keramik mungil bernuansa earth-tone. Sempurna untuk meja kerja Anda.',
      price: 25000,
      unit: 'pot',
      stock: 30,
      imageUrl:
          'https://images.unsplash.com/photo-1459411552884-841db9b3cc2a?w=600&auto=format&fit=crop&q=80',
      sellerName: 'Flora Asri Nusantara',
      sellerLocation: 'Kebayoran Baru, Jakarta Selatan',
      sellerLat: -6.2440,
      sellerLng: 106.7980,
      rating: 4.9,
    ),
    ProductModel(
      id: 'p15',
      name: 'Anggrek Bulan Ungu Mekar',
      categoryId: 'tanaman_hias',
      description:
          'Bunga anggrek bulan ungu mekar menawan dengan kuntum lebat yang tahan segar berminggu-minggu.',
      price: 110000,
      unit: 'tangkai',
      stock: 5,
      imageUrl:
          'https://images.unsplash.com/photo-1525310072745-f49212b5ac6d?w=600&auto=format&fit=crop&q=80',
      sellerName: 'Kebun Wiji Bumi Pusat',
      sellerLocation: 'Mampang Prapatan, Jakarta Selatan',
      sellerLat: -6.2520,
      sellerLng: 106.8290,
      rating: 5.0,
    ),
  ];

  static final List<UserModel> _mockUsers = [
    UserModel(
      id: 'user_1',
      name: 'Sari Lestari',
      email: 'sari@example.com',
      username: 'sari_lestari',
      // sha256 of 'password123'
      passwordHash:
          'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f',
      phone: '081234567890',
      photoUrl:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&auto=format&fit=crop&q=80',
    ),
  ];

  static final List<OrderModel> _mockOrders = [];

  // -------------------------------------------------------------
  // HELPER SIMULASI JARINGAN & ERROR
  // -------------------------------------------------------------
  Future<void> _checkSimulatedError() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (simulateNetworkError) {
      throw const SocketException(
          'Tidak dapat terhubung ke server (Simulasi Mode Offline)');
    }
  }

  // -------------------------------------------------------------
  // 1. GET /categories
  // -------------------------------------------------------------
  Future<List<CategoryModel>> getCategories() async {
    await _checkSimulatedError();
    return List<CategoryModel>.from(_mockCategories);
  }

  // -------------------------------------------------------------
  // 2. GET /products (mendukung ?category=, ?q=)
  // -------------------------------------------------------------
  Future<List<ProductModel>> getProducts({String? category, String? q}) async {
    await _checkSimulatedError();

    List<ProductModel> list = List<ProductModel>.from(_mockProducts);

    if (category != null && category.isNotEmpty && category != 'semua') {
      list = list
          .where((p) => p.categoryId.toLowerCase() == category.toLowerCase())
          .toList();
    }

    if (q != null && q.trim().isNotEmpty) {
      final query = q.toLowerCase().trim();
      list = list
          .where((p) =>
              p.name.toLowerCase().contains(query) ||
              p.description.toLowerCase().contains(query))
          .toList();
    }

    return list;
  }

  // -------------------------------------------------------------
  // 3. GET /products/{id}
  // -------------------------------------------------------------
  Future<ProductModel> getProductById(String id) async {
    await _checkSimulatedError();
    final product = _mockProducts.firstWhere(
      (p) => p.id == id,
      orElse: () => throw HttpException('Produk dengan ID $id tidak ditemukan'),
    );
    return product;
  }

  // -------------------------------------------------------------
  // 4. POST /users (Registrasi)
  // -------------------------------------------------------------
  Future<UserModel> registerUser(Map<String, dynamic> userData) async {
    await _checkSimulatedError();

    final email = userData['email']?.toString().toLowerCase().trim() ?? '';
    final username = userData['username']?.toString().trim() ?? '';

    final exists = _mockUsers.any((u) =>
        u.email.toLowerCase() == email ||
        u.username.toLowerCase() == username.toLowerCase());
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

  // -------------------------------------------------------------
  // 5. GET /users?email= / Login
  // -------------------------------------------------------------
  Future<UserModel> loginUser(String identifier, String passwordHash) async {
    await _checkSimulatedError();

    final cleanId = identifier.toLowerCase().trim();
    try {
      final user = _mockUsers.firstWhere(
        (u) =>
            (u.email.toLowerCase() == cleanId ||
                u.username.toLowerCase() == cleanId) &&
            u.passwordHash == passwordHash,
      );
      return user;
    } catch (_) {
      throw const HttpException('Email/Username atau password salah');
    }
  }

  // -------------------------------------------------------------
  // 6. PUT /users/{id} (Update Profil)
  // -------------------------------------------------------------
  Future<UserModel> updateUser(
      String userId, Map<String, dynamic> updateData) async {
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

  // -------------------------------------------------------------
  // 7. POST /orders (Buat Pesanan Baru)
  // -------------------------------------------------------------
  Future<OrderModel> createOrder(Map<String, dynamic> orderData) async {
    await _checkSimulatedError();

    final newOrder = OrderModel.fromJson(orderData);

    // Validasi stok produk sebelum order dibuat
    for (var item in newOrder.items) {
      final productIndex =
          _mockProducts.indexWhere((p) => p.id == item.productId);
      if (productIndex != -1) {
        final currentStock = _mockProducts[productIndex].stock;
        if (currentStock < item.quantity) {
          throw HttpException(
              'Stok untuk produk "${item.name}" tidak mencukupi (sisa $currentStock)');
        }
      }
    }

    // Kurangi stok produk
    for (var item in newOrder.items) {
      final productIndex =
          _mockProducts.indexWhere((p) => p.id == item.productId);
      if (productIndex != -1) {
        final current = _mockProducts[productIndex];
        _mockProducts[productIndex] = current.copyWith(
          stock: current.stock - item.quantity,
        );
      }
    }

    _mockOrders.insert(0, newOrder);
    return newOrder;
  }

  // -------------------------------------------------------------
  // 8. GET /orders?userId= (Riwayat Pesanan)
  // -------------------------------------------------------------
  Future<List<OrderModel>> getOrders(String userId) async {
    await _checkSimulatedError();
    return _mockOrders.where((o) => o.userId == userId).toList();
  }

  // -------------------------------------------------------------
  // 9. GET /orders/{id} (Detail Pesanan)
  // -------------------------------------------------------------
  Future<OrderModel> getOrderById(String id) async {
    await _checkSimulatedError();
    return _mockOrders.firstWhere(
      (o) => o.id == id,
      orElse: () =>
          throw HttpException('Pesanan dengan ID $id tidak ditemukan'),
    );
  }

  // -------------------------------------------------------------
  // 10. PATCH /orders/{id} (Ubah Status Pesanan)
  // -------------------------------------------------------------
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
