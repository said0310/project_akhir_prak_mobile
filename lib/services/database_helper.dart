import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/models.dart';

/// Database Helper untuk SQLite Lokal (Wiji Bumi)
/// Mengelola persistensi: Keranjang Belanja, Wishlist, Pengingat, dan Alamat
class DatabaseHelper {
  // Konstanta Nama & Versi Database
  static const String dbName = 'wijibumi.db';
  static const int dbVersion = 1;

  // Nama Tabel SQLite
  static const String tableCart = 'cart';
  static const String tableWishlist = 'wishlist';
  static const String tableReminders = 'reminders';
  static const String tableAddresses = 'addresses';

  // Default Lokasi Toko Pusat Wiji Bumi
  static const double storeLatitude = -6.2088;
  static const double storeLongitude = 106.8456;
  static const String storeName = 'Kebun Pusat Wiji Bumi';
  static const String storeLocationName = 'Jakarta Selatan';

  // Biaya Ongkir Default
  static const double baseDistanceKm = 5.0;
  static const double baseShippingCost = 5000.0;
  static const double perKmShippingCost = 1500.0;
  static const double maxShippingCost = 25000.0;
  static const double flatShippingCost = 10000.0;
  static const double freeShippingThreshold = 200000.0;

  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await init();
    return _database!;
  }

  static Future<Database> init() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, dbName);

    return await openDatabase(
      path,
      version: dbVersion,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    // 1. Tabel Keranjang Belanja (Cart)
    await db.execute('''
      CREATE TABLE $tableCart (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        product_id TEXT,
        name TEXT,
        price REAL,
        unit TEXT,
        image_url TEXT,
        stock INTEGER,
        quantity INTEGER,
        is_selected INTEGER
      )
    ''');

    // 2. Tabel Wishlist / Favorit
    await db.execute('''
      CREATE TABLE $tableWishlist (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        product_id TEXT,
        name TEXT,
        category_id TEXT,
        description TEXT,
        price REAL,
        unit TEXT,
        stock INTEGER,
        image_url TEXT,
        seller_name TEXT,
        seller_location TEXT,
        seller_lat REAL,
        seller_lng REAL
      )
    ''');

    // 3. Tabel Pengingat Rawat / Siram Tanaman (Reminders)
    await db.execute('''
      CREATE TABLE $tableReminders (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        title TEXT,
        scheduled_at TEXT,
        is_active INTEGER
      )
    ''');

    // 4. Tabel Alamat Pengiriman (Addresses)
    await db.execute('''
      CREATE TABLE $tableAddresses (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        recipient_name TEXT,
        phone TEXT,
        full_address TEXT,
        city TEXT,
        district TEXT,
        latitude REAL,
        longitude REAL,
        is_primary INTEGER
      )
    ''');
  }

  // ==========================================
  // 1. OPERASI CRUD KERANJANG (CART)
  // ==========================================

  static Future<List<CartItemModel>> getCartItems(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableCart,
      where: 'user_id = ? OR user_id = ? OR user_id = ?',
      whereArgs: [userId, 'guest', 'current'],
    );

    return maps.map((m) {
      return CartItemModel(
        productId: m['product_id'] as String? ?? '',
        name: m['name'] as String? ?? '',
        price: (m['price'] as num?)?.toDouble() ?? 0.0,
        unit: m['unit'] as String? ?? '',
        imageUrl: m['image_url'] as String? ?? '',
        stock: m['stock'] as int? ?? 0,
        quantity: m['quantity'] as int? ?? 1,
        isSelected: (m['is_selected'] as int? ?? 1) == 1,
        userId: m['user_id'] as String? ?? userId,
      );
    }).toList();
  }

  static Future<void> saveCartItem(CartItemModel item) async {
    final db = await database;
    final id = '${item.userId}_${item.productId}';
    final data = {
      'id': id,
      'user_id': item.userId,
      'product_id': item.productId,
      'name': item.name,
      'price': item.price,
      'unit': item.unit,
      'image_url': item.imageUrl,
      'stock': item.stock,
      'quantity': item.quantity,
      'is_selected': item.isSelected ? 1 : 0,
    };

    await db.insert(
      tableCart,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> deleteCartItem(String userId, String productId) async {
    final db = await database;
    final id = '${userId}_$productId';
    await db.delete(
      tableCart,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> clearCart(String userId) async {
    final db = await database;
    await db.delete(
      tableCart,
      where: 'user_id = ? OR user_id = ?',
      whereArgs: [userId, 'guest'],
    );
  }

  // ==========================================
  // 2. OPERASI CRUD WISHLIST
  // ==========================================

  static Future<List<ProductModel>> getWishlist(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableWishlist,
      where: 'user_id = ? OR user_id = ? OR user_id = ?',
      whereArgs: [userId, 'guest', 'current'],
    );

    return maps.map((m) {
      return ProductModel(
        id: m['product_id'] as String? ?? m['id'] as String? ?? '',
        name: m['name'] as String? ?? '',
        categoryId: m['category_id'] as String? ?? '',
        description: m['description'] as String? ?? '',
        price: (m['price'] as num?)?.toDouble() ?? 0.0,
        unit: m['unit'] as String? ?? '',
        stock: m['stock'] as int? ?? 0,
        imageUrl: m['image_url'] as String? ?? '',
        sellerName: m['seller_name'] as String? ?? '',
        sellerLocation: m['seller_location'] as String? ?? '',
        sellerLat: (m['seller_lat'] as num?)?.toDouble() ?? 0.0,
        sellerLng: (m['seller_lng'] as num?)?.toDouble() ?? 0.0,
      );
    }).toList();
  }

  static Future<bool> isFavorite(String userId, String productId) async {
    final db = await database;
    final id = '${userId}_$productId';
    final List<Map<String, dynamic>> maps = await db.query(
      tableWishlist,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return maps.isNotEmpty;
  }

  static Future<void> addWishlist(String userId, ProductModel product) async {
    final db = await database;
    final id = '${userId}_${product.id}';
    final data = {
      'id': id,
      'user_id': userId,
      'product_id': product.id,
      'name': product.name,
      'category_id': product.categoryId,
      'description': product.description,
      'price': product.price,
      'unit': product.unit,
      'stock': product.stock,
      'image_url': product.imageUrl,
      'seller_name': product.sellerName,
      'seller_location': product.sellerLocation,
      'seller_lat': product.sellerLat,
      'seller_lng': product.sellerLng,
    };

    await db.insert(
      tableWishlist,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> removeWishlist(String userId, String productId) async {
    final db = await database;
    final id = '${userId}_$productId';
    await db.delete(
      tableWishlist,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==========================================
  // 3. OPERASI CRUD PENGINGAT (REMINDERS)
  // ==========================================

  static Future<List<ReminderModel>> getReminders(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableReminders,
      where: 'user_id = ? OR user_id = ? OR user_id = ?',
      whereArgs: [userId, 'guest', 'current'],
      orderBy: 'scheduled_at DESC',
    );

    return maps.map((m) {
      return ReminderModel(
        id: m['id'] as String? ?? '',
        userId: m['user_id'] as String? ?? userId,
        title: m['title'] as String? ?? '',
        scheduledAt: DateTime.tryParse(m['scheduled_at'] as String? ?? '') ?? DateTime.now(),
        isActive: (m['is_active'] as int? ?? 1) == 1,
      );
    }).toList();
  }

  static Future<ReminderModel?> getReminderById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableReminders,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    final m = maps.first;
    return ReminderModel(
      id: m['id'] as String? ?? '',
      userId: m['user_id'] as String? ?? '',
      title: m['title'] as String? ?? '',
      scheduledAt: DateTime.tryParse(m['scheduled_at'] as String? ?? '') ?? DateTime.now(),
      isActive: (m['is_active'] as int? ?? 1) == 1,
    );
  }

  static Future<void> saveReminder(ReminderModel reminder) async {
    final db = await database;
    final data = {
      'id': reminder.id,
      'user_id': reminder.userId,
      'title': reminder.title,
      'scheduled_at': reminder.scheduledAt.toIso8601String(),
      'is_active': reminder.isActive ? 1 : 0,
    };

    await db.insert(
      tableReminders,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> deleteReminder(String id) async {
    final db = await database;
    await db.delete(
      tableReminders,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==========================================
  // 4. OPERASI CRUD ALAMAT (ADDRESSES)
  // ==========================================

  static Future<List<AddressModel>> getAddresses(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableAddresses,
      where: 'user_id = ? OR user_id = ? OR user_id = ?',
      whereArgs: [userId, 'guest', 'current'],
    );

    return maps.map((m) {
      return AddressModel(
        id: m['id'] as String? ?? '',
        userId: m['user_id'] as String? ?? userId,
        recipientName: m['recipient_name'] as String? ?? '',
        phone: m['phone'] as String? ?? '',
        fullAddress: m['full_address'] as String? ?? '',
        city: m['city'] as String? ?? '',
        district: m['district'] as String? ?? '',
        latitude: (m['latitude'] as num?)?.toDouble() ?? 0.0,
        longitude: (m['longitude'] as num?)?.toDouble() ?? 0.0,
        isPrimary: (m['is_primary'] as int? ?? 0) == 1,
      );
    }).toList();
  }

  static Future<AddressModel?> getPrimaryAddress(String userId) async {
    final list = await getAddresses(userId);
    if (list.isEmpty) return null;
    try {
      return list.firstWhere((a) => a.isPrimary);
    } catch (_) {
      return list.first;
    }
  }

  static Future<void> saveAddress(AddressModel address) async {
    final db = await database;

    // Jika dijadikan primary, update alamat lain user agar tidak primary
    if (address.isPrimary) {
      await db.update(
        tableAddresses,
        {'is_primary': 0},
        where: 'user_id = ?',
        whereArgs: [address.userId],
      );
    }

    final data = {
      'id': address.id,
      'user_id': address.userId,
      'recipient_name': address.recipientName,
      'phone': address.phone,
      'full_address': address.fullAddress,
      'city': address.city,
      'district': address.district,
      'latitude': address.latitude,
      'longitude': address.longitude,
      'is_primary': address.isPrimary ? 1 : 0,
    };

    await db.insert(
      tableAddresses,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> deleteAddress(String id) async {
    final db = await database;
    await db.delete(
      tableAddresses,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

/// Alias kompatibilitas untuk repository alamat (langsung memanggil DatabaseHelper)
class AddressRepository {
  Future<List<AddressModel>> getAddresses(String userId) => DatabaseHelper.getAddresses(userId);
  Future<AddressModel?> getPrimaryAddress(String userId) => DatabaseHelper.getPrimaryAddress(userId);
  Future<void> saveAddress(AddressModel address) => DatabaseHelper.saveAddress(address);
  Future<void> deleteAddress(String id) => DatabaseHelper.deleteAddress(id);
}
