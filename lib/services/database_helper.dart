import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/models.dart';

/// Database Helper untuk SQLite Lokal (Wiji Bumi)
/// Mengelola persistensi: Keranjang Belanja, Wishlist, Pengingat, Alamat, dan Pesanan
class DatabaseHelper {
  // Konstanta Nama & Versi Database
  static const String dbName = 'wijibumi.db';
  static const int dbVersion = 1;

  // Nama Tabel SQLite
  static const String tableUsers = 'users';
  static const String tableCart = 'cart';
  static const String tableWishlist = 'wishlist';
  static const String tableReminders = 'reminders';
  static const String tableAddresses = 'addresses';
  static const String tableOrders = 'orders';
  static const String tableOrderItems = 'order_items';

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

  /// Memuat katalog produk dari CSV aset lokal
  static Future<List<ProductModel>> loadCatalogProducts() async {
    return await ProductModel.loadFromAssets();
  }

  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await init();
    return _database!;
  }

  static Future<Database> init() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, dbName);

    final db = await openDatabase(
      path,
      version: dbVersion,
      onCreate: _onCreate,
    );

    await _ensureTables(db);
    return db;
  }

  static Future<void> _ensureTables(Database db) async {
    // 0. Tabel Pengguna (Users)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableUsers (
        id TEXT PRIMARY KEY,
        name TEXT,
        email TEXT,
        username TEXT,
        phone TEXT,
        password TEXT,
        password_hash TEXT,
        photo_url TEXT,
        created_at TEXT
      )
    ''');

    // Default mock user (Sari Lestari) agar akun bawaan tersedia di database
    try {
      await db.insert(
        tableUsers,
        {
          'id': 'user_1',
          'name': 'Sari Lestari',
          'email': 'sari@example.com',
          'username': 'sari_lestari',
          'phone': '081234567890',
          'password': 'password123',
          'password_hash': 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f',
          'photo_url': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&auto=format&fit=crop&q=80',
          'created_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    } catch (_) {}

    // 1. Tabel Pesanan (Orders)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableOrders (
        id TEXT PRIMARY KEY,
        order_number TEXT,
        user_id TEXT,
        customer_name TEXT,
        user_name TEXT,
        created_at TEXT,
        status TEXT,
        payment_method TEXT,
        shipping_address TEXT,
        address_json TEXT,
        subtotal REAL,
        shipping_cost REAL,
        total REAL,
        items_json TEXT
      )
    ''');

    // Tambah kolom ke tabel orders jika database sudah ada sebelumnya (migrasi aman)
    try {
      await db.execute('ALTER TABLE $tableOrders ADD COLUMN customer_name TEXT');
    } catch (_) {}
    try {
      await db.execute('ALTER TABLE $tableOrders ADD COLUMN user_name TEXT');
    } catch (_) {}
    try {
      await db.execute('ALTER TABLE $tableOrders ADD COLUMN shipping_address TEXT');
    } catch (_) {}

    // 2. Tabel Rincian Barang Pesanan (Order Items) Terstruktur
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableOrderItems (
        id TEXT PRIMARY KEY,
        order_id TEXT,
        product_id TEXT,
        product_name TEXT,
        price REAL,
        quantity INTEGER,
        subtotal REAL
      )
    ''');

    // Migrasi data lama dari items_json ke tabel relasi order_items
    try {
      final List<Map<String, dynamic>> existingOrders = await db.query(tableOrders);
      for (final row in existingOrders) {
        final orderId = row['id'] as String? ?? '';
        final itemsJson = row['items_json'] as String? ?? '[]';
        if (orderId.isNotEmpty && itemsJson.isNotEmpty) {
          final countRes = Sqflite.firstIntValue(await db.rawQuery(
            'SELECT COUNT(*) FROM $tableOrderItems WHERE order_id = ?',
            [orderId],
          ));
          if ((countRes ?? 0) == 0) {
            final decoded = jsonDecode(itemsJson);
            if (decoded is List) {
              for (final it in decoded) {
                if (it is Map<String, dynamic>) {
                  final pId = it['productId']?.toString() ?? it['product_id']?.toString() ?? '';
                  final pName = it['name']?.toString() ?? it['product_name']?.toString() ?? '';
                  final pPrice = (it['price'] as num?)?.toDouble() ?? 0.0;
                  final pQty = (it['quantity'] as num?)?.toInt() ?? 1;
                  final pSubtotal = (it['subtotal'] as num?)?.toDouble() ?? (pPrice * pQty);
                  await db.insert(
                    tableOrderItems,
                    {
                      'id': '${orderId}_$pId',
                      'order_id': orderId,
                      'product_id': pId,
                      'product_name': pName,
                      'price': pPrice,
                      'quantity': pQty,
                      'subtotal': pSubtotal,
                    },
                    conflictAlgorithm: ConflictAlgorithm.replace,
                  );
                }
              }
            }
          }
        }
      }
    } catch (_) {}

    // Kolom baru untuk notifikasi & pengingat (message & is_read)
    try {
      await db.execute('ALTER TABLE $tableReminders ADD COLUMN message TEXT');
    } catch (_) {}
    try {
      await db.execute('ALTER TABLE $tableReminders ADD COLUMN is_read INTEGER DEFAULT 0');
    } catch (_) {}
  }

  static Future<void> _onCreate(Database db, int version) async {
    // 0. Tabel Pengguna (Users)
    await db.execute('''
      CREATE TABLE $tableUsers (
        id TEXT PRIMARY KEY,
        name TEXT,
        email TEXT,
        username TEXT,
        phone TEXT,
        password TEXT,
        password_hash TEXT,
        photo_url TEXT,
        created_at TEXT
      )
    ''');

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

    // 3. Tabel Pengingat Rawat / Siram Tanaman & Notifikasi (Reminders)
    await db.execute('''
      CREATE TABLE $tableReminders (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        title TEXT,
        message TEXT,
        scheduled_at TEXT,
        is_active INTEGER,
        is_read INTEGER DEFAULT 0
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

    // 5. Tabel Pesanan (Orders) & Tabel Rincian (Order Items)
    await _ensureTables(db);
  }

  // ==========================================
  // 0. OPERASI CRUD PENGGUNA (USERS)
  // ==========================================

  static Future<void> saveUser({
    required String id,
    required String name,
    required String email,
    required String username,
    required String phone,
    required String password,
    String? passwordHash,
    String? photoUrl,
    String? createdAt,
  }) async {
    final db = await database;
    await _ensureTables(db);
    final data = {
      'id': id,
      'name': name,
      'email': email,
      'username': username,
      'phone': phone,
      'password': password,
      'password_hash': passwordHash ?? '',
      'photo_url': photoUrl ?? '',
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
    };

    await db.insert(
      tableUsers,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<Map<String, dynamic>?> getUserById(String id) async {
    final db = await database;
    await _ensureTables(db);
    final List<Map<String, dynamic>> maps = await db.query(
      tableUsers,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return maps.first;
  }

  static Future<Map<String, dynamic>?> getUserByEmailOrUsername(String identifier) async {
    final db = await database;
    await _ensureTables(db);
    final clean = identifier.toLowerCase().trim();
    final List<Map<String, dynamic>> maps = await db.query(
      tableUsers,
      where: 'LOWER(email) = ? OR LOWER(username) = ?',
      whereArgs: [clean, clean],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return maps.first;
  }

  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await database;
    await _ensureTables(db);
    return await db.query(tableUsers, orderBy: 'created_at DESC');
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
        message: m['message'] as String?,
        scheduledAt: DateTime.tryParse(m['scheduled_at'] as String? ?? '') ?? DateTime.now(),
        isActive: (m['is_active'] as int? ?? 1) == 1,
        isRead: (m['is_read'] as int? ?? 0) == 1,
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
      message: m['message'] as String?,
      scheduledAt: DateTime.tryParse(m['scheduled_at'] as String? ?? '') ?? DateTime.now(),
      isActive: (m['is_active'] as int? ?? 1) == 1,
      isRead: (m['is_read'] as int? ?? 0) == 1,
    );
  }

  static Future<void> saveReminder(ReminderModel reminder) async {
    final db = await database;
    final data = {
      'id': reminder.id,
      'user_id': reminder.userId,
      'title': reminder.title,
      'message': reminder.message ?? '',
      'scheduled_at': reminder.scheduledAt.toIso8601String(),
      'is_active': reminder.isActive ? 1 : 0,
      'is_read': reminder.isRead ? 1 : 0,
    };

    await db.insert(
      tableReminders,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> markReminderAsRead(String id, bool isRead) async {
    final db = await database;
    await db.update(
      tableReminders,
      {'is_read': isRead ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> markAllRemindersAsRead(String userId) async {
    final db = await database;
    await db.update(
      tableReminders,
      {'is_read': 1},
      where: 'user_id = ? OR user_id = ? OR user_id = ?',
      whereArgs: [userId, 'guest', 'current'],
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

  // ==========================================
  // 5. OPERASI CRUD PESANAN (ORDERS & ORDER ITEMS)
  // ==========================================

  static Future<void> saveOrder(OrderModel order) async {
    final db = await database;
    await _ensureTables(db);

    final recipientName = order.address.recipientName.isNotEmpty
        ? order.address.recipientName
        : 'Pengguna Wiji Bumi';

    final fullAddressText = [
      if (order.address.recipientName.isNotEmpty) '${order.address.recipientName} (${order.address.phone})',
      if (order.address.fullAddress.isNotEmpty) order.address.fullAddress,
      if (order.address.district.isNotEmpty) order.address.district,
      if (order.address.city.isNotEmpty) order.address.city,
    ].join(', ');

    // 1. Simpan ke tabel utama orders
    final data = {
      'id': order.id,
      'order_number': order.orderNumber,
      'user_id': order.userId,
      'customer_name': recipientName,
      'user_name': recipientName,
      'created_at': order.createdAt.toIso8601String(),
      'status': order.status,
      'payment_method': order.paymentMethod,
      'shipping_address': fullAddressText.isNotEmpty ? fullAddressText : order.address.fullAddress,
      'address_json': jsonEncode(order.address.toJson()),
      'subtotal': order.subtotal,
      'shipping_cost': order.shippingCost,
      'total': order.total,
      'items_json': jsonEncode(order.items.map((i) => i.toJson()).toList()),
    };

    await db.insert(
      tableOrders,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // 2. Simpan setiap rincian barang secara terstruktur ke tabel order_items
    for (final item in order.items) {
      final itemId = '${order.id}_${item.productId}';
      await db.insert(
        tableOrderItems,
        {
          'id': itemId,
          'order_id': order.id,
          'product_id': item.productId,
          'product_name': item.name,
          'price': item.price,
          'quantity': item.quantity,
          'subtotal': item.subtotal,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  static Future<List<OrderModel>> getOrders(String userId) async {
    final db = await database;
    await _ensureTables(db);
    final List<Map<String, dynamic>> maps = await db.query(
      tableOrders,
      where: 'user_id = ? OR user_id = ? OR user_id = ?',
      whereArgs: [userId, 'guest', 'current'],
      orderBy: 'created_at DESC',
    );

    final List<OrderModel> orders = [];
    for (final m in maps) {
      AddressModel address;
      try {
        address = AddressModel.fromJson(
          jsonDecode(m['address_json'] as String? ?? '{}'),
        );
      } catch (_) {
        address = AddressModel(
          id: '0',
          userId: userId,
          recipientName: m['customer_name'] as String? ?? m['user_name'] as String? ?? 'Penerima',
          phone: '-',
          fullAddress: m['shipping_address'] as String? ?? '-',
          city: '-',
          district: '-',
          latitude: 0,
          longitude: 0,
        );
      }

      List<OrderItemModel> items = [];
      try {
        final decoded = jsonDecode(m['items_json'] as String? ?? '[]');
        if (decoded is List && decoded.isNotEmpty) {
          items = decoded
              .map((i) => OrderItemModel.fromJson(i as Map<String, dynamic>))
              .toList();
        }
      } catch (_) {}

      // Jika items_json kosong, ambil langsung dari tabel relasi terstruktur order_items
      if (items.isEmpty) {
        final orderId = m['id'] as String? ?? '';
        final itemRows = await db.query(
          tableOrderItems,
          where: 'order_id = ?',
          whereArgs: [orderId],
        );
        items = itemRows.map((r) => OrderItemModel(
          productId: r['product_id'] as String? ?? '',
          name: r['product_name'] as String? ?? '',
          price: (r['price'] as num?)?.toDouble() ?? 0.0,
          unit: 'unit',
          quantity: (r['quantity'] as num?)?.toInt() ?? 1,
          subtotal: (r['subtotal'] as num?)?.toDouble() ?? 0.0,
        )).toList();
      }

      orders.add(OrderModel(
        id: m['id'] as String? ?? '',
        orderNumber: m['order_number'] as String? ?? '',
        userId: m['user_id'] as String? ?? userId,
        createdAt: DateTime.tryParse(m['created_at'] as String? ?? '') ?? DateTime.now(),
        status: m['status'] as String? ?? 'Menunggu Pembayaran',
        paymentMethod: m['payment_method'] as String? ?? 'Transfer Bank',
        address: address,
        subtotal: (m['subtotal'] as num?)?.toDouble() ?? 0.0,
        shippingCost: (m['shipping_cost'] as num?)?.toDouble() ?? 0.0,
        total: (m['total'] as num?)?.toDouble() ?? 0.0,
        items: items,
      ));
    }

    return orders;
  }

  static Future<List<Map<String, dynamic>>> getOrderItems(String orderId) async {
    final db = await database;
    await _ensureTables(db);
    return await db.query(
      tableOrderItems,
      where: 'order_id = ?',
      whereArgs: [orderId],
    );
  }

  static Future<List<Map<String, dynamic>>> getAllOrderItems() async {
    final db = await database;
    await _ensureTables(db);
    return await db.query(tableOrderItems);
  }

  static Future<void> updateOrderPaymentMethod(String orderId, String newMethod) async {
    final db = await database;
    await _ensureTables(db);
    await db.update(
      tableOrders,
      {'payment_method': newMethod},
      where: 'id = ?',
      whereArgs: [orderId],
    );
  }

  static Future<void> updateOrderStatus(String orderId, String newStatus) async {
    final db = await database;
    await _ensureTables(db);
    await db.update(
      tableOrders,
      {'status': newStatus},
      where: 'id = ?',
      whereArgs: [orderId],
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
