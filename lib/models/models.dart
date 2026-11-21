import 'package:flutter/services.dart' show rootBundle;

/// ============================================================================
/// 1. MODEL PENGGUNA (USER)
/// ============================================================================
class UserModel {
  final String id;
  final String name;
  final String email;
  final String username;
  final String passwordHash;
  final String phone;
  final String photoUrl;
  final String createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.username,
    required this.passwordHash,
    this.phone = '',
    this.photoUrl = '',
    String? createdAt,
  }) : createdAt = createdAt ?? DateTime.now().toIso8601String();

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      passwordHash: json['passwordHash']?.toString() ?? json['password_hash']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      photoUrl: json['photoUrl']?.toString() ?? json['photo_url']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? json['created_at']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'username': username,
      'passwordHash': passwordHash,
      'phone': phone,
      'photoUrl': photoUrl,
      'createdAt': createdAt,
      'created_at': createdAt,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? username,
    String? passwordHash,
    String? phone,
    String? photoUrl,
    String? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      username: username ?? this.username,
      passwordHash: passwordHash ?? this.passwordHash,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// ============================================================================
/// 2. MODEL KATEGORI PRODUK
/// ============================================================================
class CategoryModel {
  final String id;
  final String name;
  final String icon;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      icon: json['icon']?.toString() ?? 'eco',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
    };
  }

  /// Mengekstrak daftar kategori unik dari list produk dan memberi nama serta ikon yang sesuai
  static List<CategoryModel> fromProductList(List<ProductModel> products) {
    final seen = <String>{};
    final List<CategoryModel> list = [];

    final categoryMeta = {
      'buah': {'name': 'Buah', 'icon': 'apple'},
      'sayur': {'name': 'Sayuran', 'icon': 'grass'},
      'sayuran': {'name': 'Sayuran', 'icon': 'grass'},
      'bunga': {'name': 'Bunga', 'icon': 'local_florist'},
      'tanaman_hias': {'name': 'Bunga', 'icon': 'yard'},
      'beras&umbi-umbian': {'name': 'Beras & Umbi', 'icon': 'grain'},
      'rempah-rempah': {'name': 'Rempah', 'icon': 'spa'},
    };

    for (var product in products) {
      final rawId = product.categoryId.trim();
      final catId = rawId.toLowerCase();
      if (catId.isNotEmpty && seen.add(catId)) {
        final meta = categoryMeta[catId];
        final name = meta?['name'] ??
            (rawId.length > 1
                ? rawId[0].toUpperCase() + rawId.substring(1)
                : rawId);
        final icon = meta?['icon'] ?? 'eco';
        list.add(CategoryModel(
          id: rawId,
          name: name,
          icon: icon,
        ));
      }
    }
    return list;
  }
}

/// ============================================================================
/// 3. MODEL PRODUK (PRODUCT)
/// ============================================================================
class ProductModel {
  final String id;
  final String name;
  final String categoryId;
  final String description;
  final double price;
  final String unit; // kg, gram, ikat, buah, pot, tangkai
  final int stock;
  final String imageUrl;
  final String sellerName;
  final String sellerLocation;
  final double sellerLat;
  final double sellerLng;
  final double rating;
  final String origin;
  final bool isFeatured;

  ProductModel({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.description,
    required this.price,
    required this.unit,
    required this.stock,
    required this.imageUrl,
    required this.sellerName,
    required this.sellerLocation,
    required this.sellerLat,
    required this.sellerLng,
    this.rating = 4.8,
    this.origin = '',
    this.isFeatured = false,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      categoryId: json['categoryId']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit']?.toString() ?? 'kg',
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      imageUrl: json['imageUrl']?.toString() ?? '',
      sellerName: json['sellerName']?.toString() ?? 'Kebun Wiji Bumi',
      sellerLocation: json['sellerLocation']?.toString() ??
          ((json['origin']?.toString().isNotEmpty == true)
              ? json['origin'].toString()
              : 'Jakarta'),
      sellerLat: (json['sellerLat'] as num?)?.toDouble() ?? -6.2088,
      sellerLng: (json['sellerLng'] as num?)?.toDouble() ?? 106.8456,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
      origin: json['origin']?.toString() ?? '',
      isFeatured: json['isFeatured'] == true ||
          json['is_featured'] == 1 ||
          json['is_featured'] == '1',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'categoryId': categoryId,
      'description': description,
      'price': price,
      'unit': unit,
      'stock': stock,
      'imageUrl': imageUrl,
      'sellerName': sellerName,
      'sellerLocation': sellerLocation,
      'sellerLat': sellerLat,
      'sellerLng': sellerLng,
      'rating': rating,
      'origin': origin,
      'isFeatured': isFeatured,
      'is_featured': isFeatured ? 1 : 0,
    };
  }

  ProductModel copyWith({
    String? id,
    String? name,
    String? categoryId,
    String? description,
    double? price,
    String? unit,
    int? stock,
    String? imageUrl,
    String? sellerName,
    String? sellerLocation,
    double? sellerLat,
    double? sellerLng,
    double? rating,
    String? origin,
    bool? isFeatured,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      description: description ?? this.description,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      stock: stock ?? this.stock,
      imageUrl: imageUrl ?? this.imageUrl,
      sellerName: sellerName ?? this.sellerName,
      sellerLocation: sellerLocation ?? this.sellerLocation,
      sellerLat: sellerLat ?? this.sellerLat,
      sellerLng: sellerLng ?? this.sellerLng,
      rating: rating ?? this.rating,
      origin: origin ?? this.origin,
      isFeatured: isFeatured ?? this.isFeatured,
    );
  }

  /// Memastikan nama gambar produk memiliki prefix assets/images/products/ jika berupa nama file lokal
  static String resolveImagePath(String image) {
    final clean = image.trim();
    if (clean.isEmpty) return '';
    if (clean.startsWith('http://') || clean.startsWith('https://')) return clean;
    if (clean.startsWith('assets/')) return clean;
    return 'assets/images/products/$clean';
  }

  /// Parser CSV fleksibel: mendukung pemisah kolom koma (,) atau titik koma (;),
  /// teks di dalam tanda kutip ("..."), escape quote (""), baris baru dalam kutip, serta trimming.
  static List<List<String>> parseCsvString(String rawCsv, {String? delimiter}) {
    final cleanInput = rawCsv.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    if (cleanInput.trim().isEmpty) return [];

    // Deteksi pemisah otomatis
    String sep = delimiter ?? ';';
    if (delimiter == null) {
      final firstLine = cleanInput.split('\n').firstWhere(
            (line) => line.trim().isNotEmpty,
            orElse: () => '',
          );
      final semicolonCount = ';'.allMatches(firstLine).length;
      final commaCount = ','.allMatches(firstLine).length;
      sep = semicolonCount >= commaCount ? ';' : ',';
    }

    final List<List<String>> rows = [];
    List<String> currentRow = [];
    final StringBuffer currentField = StringBuffer();
    bool inQuotes = false;
    int i = 0;

    while (i < cleanInput.length) {
      final char = cleanInput[i];

      if (inQuotes) {
        if (char == '"') {
          if (i + 1 < cleanInput.length && cleanInput[i + 1] == '"') {
            currentField.write('"');
            i += 2;
            continue;
          } else {
            inQuotes = false;
            i++;
            continue;
          }
        } else {
          currentField.write(char);
          i++;
          continue;
        }
      } else {
        if (char == '"') {
          inQuotes = true;
          i++;
          continue;
        } else if (char == sep) {
          currentRow.add(currentField.toString().trim());
          currentField.clear();
          i++;
          continue;
        } else if (char == '\n') {
          currentRow.add(currentField.toString().trim());
          currentField.clear();
          if (currentRow.any((field) => field.isNotEmpty)) {
            rows.add(currentRow);
          }
          currentRow = [];
          i++;
          continue;
        } else {
          currentField.write(char);
          i++;
          continue;
        }
      }
    }

    if (currentField.isNotEmpty || currentRow.isNotEmpty) {
      currentRow.add(currentField.toString().trim());
      if (currentRow.any((field) => field.isNotEmpty)) {
        rows.add(currentRow);
      }
    }

    return rows;
  }

  /// Memetakan string CSV (misal hasil dari rootBundle.loadString) ke struktur List<ProductModel>
  static List<ProductModel> fromCsv(String rawCsv, {String? delimiter}) {
    final rows = parseCsvString(rawCsv, delimiter: delimiter);
    if (rows.isEmpty) return [];

    final headerRow = rows.first;
    final Map<String, int> headerMap = {};
    for (int i = 0; i < headerRow.length; i++) {
      headerMap[headerRow[i].toLowerCase().trim()] = i;
    }

    final List<ProductModel> products = [];
    for (int r = 1; r < rows.length; r++) {
      final row = rows[r];
      if (row.isEmpty || !row.any((f) => f.isNotEmpty)) continue;

      String getField(String key) {
        final idx = headerMap[key];
        if (idx != null && idx < row.length) {
          return row[idx].trim();
        }
        return '';
      }

      final id = getField('id');
      if (id.isEmpty) continue;

      final name = getField('name');
      final image = getField('image');
      final category = getField('category');
      final priceStr = getField('price');
      final unit = getField('unit');
      final stockStr = getField('stock');
      final description = getField('description');
      final origin = getField('origin');
      final isFeaturedStr = getField('is_featured');

      final cleanPriceStr = priceStr.replaceAll(RegExp(r'[^0-9.]'), '');
      final price = double.tryParse(cleanPriceStr) ?? 0.0;
      final cleanStockStr = stockStr.replaceAll(RegExp(r'[^0-9]'), '');
      final stock = int.tryParse(cleanStockStr) ?? 0;
      final isFeatured = isFeaturedStr == '1' || isFeaturedStr.toLowerCase() == 'true';

      products.add(ProductModel(
        id: id,
        name: name,
        categoryId: category,
        description: description,
        price: price,
        unit: unit.isNotEmpty ? unit : 'kg',
        stock: stock,
        imageUrl: resolveImagePath(image),
        sellerName: 'Kebun Wiji Bumi',
        sellerLocation: origin.isNotEmpty ? origin : 'Jakarta',
        sellerLat: -6.2088,
        sellerLng: 106.8456,
        rating: 4.8,
        origin: origin,
        isFeatured: isFeatured,
      ));
    }

    return products;
  }

  /// Membaca file CSV dari aset menggunakan rootBundle.loadString dan memetakannya ke List<ProductModel>
  static Future<List<ProductModel>> loadFromAssets({
    String path = 'assets/data/Katalog_WijiBumi.csv',
  }) async {
    final csvString = await rootBundle.loadString(path);
    return fromCsv(csvString);
  }
}

/// ============================================================================
/// 4. MODEL ITEM KERANJANG (CART ITEM)
/// ============================================================================
class CartItemModel {
  final String productId;
  final String name;
  final double price;
  final String unit;
  final String imageUrl;
  final int stock;
  int quantity;
  bool isSelected;
  final String userId;

  CartItemModel({
    required this.productId,
    required this.name,
    required this.price,
    required this.unit,
    required this.imageUrl,
    required this.stock,
    this.quantity = 1,
    this.isSelected = true,
    required this.userId,
  });

  double get subtotal => price * quantity;

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      productId: json['productId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit']?.toString() ?? 'kg',
      imageUrl: json['imageUrl']?.toString() ?? '',
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      isSelected: json['isSelected'] as bool? ?? true,
      userId: json['userId']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'unit': unit,
      'imageUrl': imageUrl,
      'stock': stock,
      'quantity': quantity,
      'isSelected': isSelected,
      'userId': userId,
    };
  }

  CartItemModel copyWith({
    String? productId,
    String? name,
    double? price,
    String? unit,
    String? imageUrl,
    int? stock,
    int? quantity,
    bool? isSelected,
    String? userId,
  }) {
    return CartItemModel(
      productId: productId ?? this.productId,
      name: name ?? this.name,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      imageUrl: imageUrl ?? this.imageUrl,
      stock: stock ?? this.stock,
      quantity: quantity ?? this.quantity,
      isSelected: isSelected ?? this.isSelected,
      userId: userId ?? this.userId,
    );
  }
}

/// ============================================================================
/// 5. MODEL ALAMAT PENGIRIMAN (ADDRESS)
/// ============================================================================
class AddressModel {
  final String id;
  final String userId;
  final String recipientName;
  final String phone;
  final String fullAddress;
  final String city;
  final String district;
  final double latitude;
  final double longitude;
  final bool isPrimary;

  AddressModel({
    required this.id,
    required this.userId,
    required this.recipientName,
    required this.phone,
    required this.fullAddress,
    required this.city,
    required this.district,
    required this.latitude,
    required this.longitude,
    this.isPrimary = false,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      recipientName: json['recipientName']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      fullAddress: json['fullAddress']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      district: json['district']?.toString() ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      isPrimary: json['isPrimary'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'recipientName': recipientName,
      'phone': phone,
      'fullAddress': fullAddress,
      'city': city,
      'district': district,
      'latitude': latitude,
      'longitude': longitude,
      'isPrimary': isPrimary,
    };
  }

  AddressModel copyWith({
    String? id,
    String? userId,
    String? recipientName,
    String? phone,
    String? fullAddress,
    String? city,
    String? district,
    double? latitude,
    double? longitude,
    bool? isPrimary,
  }) {
    return AddressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      recipientName: recipientName ?? this.recipientName,
      phone: phone ?? this.phone,
      fullAddress: fullAddress ?? this.fullAddress,
      city: city ?? this.city,
      district: district ?? this.district,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }
}

/// ============================================================================
/// 6. MODEL PENGINGAT (REMINDER)
/// ============================================================================
class ReminderModel {
  final String id;
  final String userId;
  final String title;
  final String? message;
  final DateTime scheduledAt;
  bool isActive;
  bool isRead;

  ReminderModel({
    required this.id,
    required this.userId,
    required this.title,
    this.message,
    required this.scheduledAt,
    this.isActive = true,
    this.isRead = false,
  });

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString(),
      scheduledAt: json['scheduledAt'] != null
          ? DateTime.tryParse(json['scheduledAt'].toString()) ?? DateTime.now()
          : (json['scheduled_at'] != null
              ? DateTime.tryParse(json['scheduled_at'].toString()) ?? DateTime.now()
              : DateTime.now()),
      isActive: json['isActive'] as bool? ?? (json['is_active'] as int? ?? 1) == 1,
      isRead: json['isRead'] as bool? ?? (json['is_read'] as int? ?? 0) == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'message': message,
      'scheduledAt': scheduledAt.toIso8601String(),
      'scheduled_at': scheduledAt.toIso8601String(),
      'isActive': isActive,
      'is_active': isActive ? 1 : 0,
      'isRead': isRead,
      'is_read': isRead ? 1 : 0,
    };
  }

  ReminderModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    DateTime? scheduledAt,
    bool? isActive,
    bool? isRead,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      isActive: isActive ?? this.isActive,
      isRead: isRead ?? this.isRead,
    );
  }
}

/// ============================================================================
/// 7. MODEL ITEM PESANAN & PESANAN (ORDER ITEM & ORDER)
/// ============================================================================
class OrderItemModel {
  final String productId;
  final String name;
  final double price;
  final String unit;
  final int quantity;
  final double subtotal;

  OrderItemModel({
    required this.productId,
    required this.name,
    required this.price,
    required this.unit,
    required this.quantity,
    required this.subtotal,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productId: json['productId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit']?.toString() ?? 'kg',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'unit': unit,
      'quantity': quantity,
      'subtotal': subtotal,
    };
  }
}

class OrderModel {
  final String id;
  final String orderNumber; // Format: WB-YYYYMMDD-XXXX
  final String userId;
  final DateTime createdAt;
  final String status; // Menunggu Pembayaran, Diproses, Dikemas, Dikirim, Selesai, Dibatalkan
  final String paymentMethod; // Transfer Bank, E-Wallet, COD
  final AddressModel address; // Snapshot alamat
  final double subtotal;
  final double shippingCost;
  final double total;
  final List<OrderItemModel> items;

  String get customerName =>
      address.recipientName.isNotEmpty ? address.recipientName : 'Pengguna Wiji Bumi';

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.userId,
    required this.createdAt,
    required this.status,
    required this.paymentMethod,
    required this.address,
    required this.subtotal,
    required this.shippingCost,
    required this.total,
    required this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id']?.toString() ?? '',
      orderNumber: json['orderNumber']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      status: json['status']?.toString() ?? 'Menunggu Pembayaran',
      paymentMethod: json['paymentMethod']?.toString() ?? 'Transfer Bank',
      address: json['address'] is Map<String, dynamic>
          ? AddressModel.fromJson(json['address'])
          : AddressModel(
              id: '0',
              userId: '',
              recipientName: 'Penerima',
              phone: '-',
              fullAddress: json['address']?.toString() ?? '-',
              city: '-',
              district: '-',
              latitude: 0,
              longitude: 0,
            ),
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      shippingCost: (json['shippingCost'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => OrderItemModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
      'paymentMethod': paymentMethod,
      'address': address.toJson(),
      'subtotal': subtotal,
      'shippingCost': shippingCost,
      'total': total,
      'items': items.map((i) => i.toJson()).toList(),
    };
  }

  OrderModel copyWith({
    String? id,
    String? orderNumber,
    String? userId,
    DateTime? createdAt,
    String? status,
    String? paymentMethod,
    AddressModel? address,
    double? subtotal,
    double? shippingCost,
    double? total,
    List<OrderItemModel>? items,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      address: address ?? this.address,
      subtotal: subtotal ?? this.subtotal,
      shippingCost: shippingCost ?? this.shippingCost,
      total: total ?? this.total,
      items: items ?? this.items,
    );
  }
}
