import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wijibumi/services/location_service.dart';
import 'package:wijibumi/models/models.dart';
import 'package:wijibumi/services/api_service.dart';
import 'package:wijibumi/controllers/shop_controller.dart';

void main() {
  group('Aturan Bisnis & Logika Wiji Bumi (PRD v1.0)', () {
    test('BR-06: Perhitungan Ongkos Kirim', () {
      // 1. Jarak <= 5 km -> Rp 5.000
      expect(
        LocationService.calculateShippingCost(distanceKm: 3.2, subtotal: 50000),
        5000.0,
      );
      expect(
        LocationService.calculateShippingCost(distanceKm: 5.0, subtotal: 50000),
        5000.0,
      );

      // 2. Jarak > 5 km -> 5000 + ceil(jarak - 5) * 1500
      // 6.2 km -> 5000 + 2 * 1500 = 8000
      expect(
        LocationService.calculateShippingCost(distanceKm: 6.2, subtotal: 50000),
        8000.0,
      );

      // 3. Jarak sangat jauh -> Maksimum Rp 25.000
      expect(
        LocationService.calculateShippingCost(distanceKm: 40.0, subtotal: 50000),
        25000.0,
      );

      // 4. Lokasi tidak tersedia (null) -> Flat Rp 10.000
      expect(
        LocationService.calculateShippingCost(distanceKm: null, subtotal: 50000),
        10000.0,
      );

      // 5. Gratis Ongkir jika subtotal >= Rp 200.000
      expect(
        LocationService.calculateShippingCost(distanceKm: 8.5, subtotal: 200000),
        0.0,
      );
      expect(
        LocationService.calculateShippingCost(distanceKm: 8.5, subtotal: 250000),
        0.0,
      );
    });

    test('BR-07: Format Nomor Pesanan Unik WB-YYYYMMDD-XXXX', () {
      final orderNumber = OrderRepository.generateOrderNumber();
      expect(orderNumber.startsWith('WB-'), isTrue);
      // Format regex: WB-\d{8}-\d{4}
      final regex = RegExp(r'^WB-\d{8}-\d{4}$');
      expect(regex.hasMatch(orderNumber), isTrue);
    });

    test('FR-AUTH-06: Password Hashing SHA-256', () {
      const password = 'password123';
      final digest = sha256.convert(utf8.encode(password)).toString();
      expect(digest, isNotEmpty);
      expect(digest.length, 64); // SHA-256 menghasilkan heksadesimal 64 karakter
      expect(digest, equals('ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f'));
    });

    test('FR-CART-05 & CartItemModel: Perhitungan Subtotal', () {
      final item = CartItemModel(
        productId: 'p1',
        name: 'Bayam Hijau',
        price: 6500,
        unit: 'ikat',
        imageUrl: '',
        stock: 10,
        quantity: 3,
        userId: 'user_1',
      );

      expect(item.subtotal, 19500.0);
    });

    test('ProductModel: Validasi data model produk', () {
      final product = ProductModel(
        id: 'p1',
        name: 'Kangkung',
        categoryId: 'sayuran',
        description: 'Kangkung segar',
        price: 5000,
        unit: 'ikat',
        stock: 20,
        imageUrl: 'http://example.com/kangkung.jpg',
        sellerName: 'Kebun Tani',
        sellerLocation: 'Jakarta',
        sellerLat: -6.2,
        sellerLng: 106.8,
      );

      final json = product.toJson();
      final copy = ProductModel.fromJson(json);

      expect(copy.id, product.id);
      expect(copy.name, product.name);
      expect(copy.price, product.price);
      expect(copy.stock, product.stock);
    });

    test('AddressModel: Serialisasi dan Deserialisasi Alamat', () {
      final addr = AddressModel(
        id: 'addr_1',
        userId: 'user_1',
        recipientName: 'Sari Lestari',
        phone: '081234567890',
        fullAddress: 'Jl. Kemang Raya No. 12',
        city: 'Jakarta Selatan',
        district: 'Mampang Prapatan',
        latitude: -6.2520,
        longitude: 106.8290,
        isPrimary: true,
      );

      final json = addr.toJson();
      final copy = AddressModel.fromJson(json);

      expect(copy.id, addr.id);
      expect(copy.recipientName, addr.recipientName);
      expect(copy.phone, addr.phone);
      expect(copy.fullAddress, addr.fullAddress);
      expect(copy.latitude, addr.latitude);
      expect(copy.isPrimary, isTrue);
    });

    test('ProductController: Filter Kategori & Sortir', () {
      final mockRepo = ProductRepository(apiService: ApiService());
      final controller = ProductController(productRepository: mockRepo);

      expect(controller.selectedCategory.value, 'semua');
      controller.selectCategory('sayuran');
      expect(controller.selectedCategory.value, 'sayuran');

      expect(controller.priceSortOrder.value, PriceSortOrder.none);
      controller.toggleSortPrice();
      expect(controller.priceSortOrder.value, PriceSortOrder.lowest);
      controller.toggleSortPrice();
      expect(controller.priceSortOrder.value, PriceSortOrder.highest);
      controller.toggleSortPrice();
      expect(controller.priceSortOrder.value, PriceSortOrder.none);

      expect(controller.filterInStockOnly.value, isFalse);
      controller.toggleFilterStock();
      expect(controller.filterInStockOnly.value, isTrue);
    });

    test('CSV Parsing: Parsing Katalog_WijiBumi dan pemetaan model', () {
      const sampleCsv = '''
id;name;image;category;price;unit;stock;description;origin;is_featured
FRU001;Alpukat;FRU001.jpg;buah;20000;kg;60;Alpukat berdaging lembut;Magelang;1
FRU002;Anggur;FRU002.jpg;buah;45000;kg;40;Anggur berair;Probolinggo;0
FLW001;Mawar Merah;FLW001.jpg;bunga;30000;ikat;40;"Mawar merah, indah";Lembang;1
''';

      final products = ProductModel.fromCsv(sampleCsv);
      expect(products.length, 3);

      expect(products[0].id, 'FRU001');
      expect(products[0].name, 'Alpukat');
      expect(products[0].imageUrl, 'assets/images/products/FRU001.jpg');
      expect(products[0].categoryId, 'buah');
      expect(products[0].price, 20000.0);
      expect(products[0].unit, 'kg');
      expect(products[0].stock, 60);
      expect(products[0].origin, 'Magelang');
      expect(products[0].isFeatured, isTrue);

      expect(products[2].id, 'FLW001');
      expect(products[2].imageUrl, 'assets/images/products/FLW001.jpg');
      expect(products[2].description, 'Mawar merah, indah');
      expect(products[2].isFeatured, isTrue);

      // Resolusi path gambar
      expect(ProductModel.resolveImagePath('FLW001.jpg'), 'assets/images/products/FLW001.jpg');
      expect(ProductModel.resolveImagePath('assets/images/products/FLW001.jpg'), 'assets/images/products/FLW001.jpg');
      expect(ProductModel.resolveImagePath('https://example.com/pic.jpg'), 'https://example.com/pic.jpg');

      // Ekstraksi kategori
      final categories = CategoryModel.fromProductList(products);
      expect(categories.any((c) => c.id == 'buah'), isTrue);
      expect(categories.any((c) => c.id == 'bunga'), isTrue);
    });

    test('Order & Payment: Pembaruan Metode Pembayaran Pesanan', () async {
      final apiService = ApiService();
      final order = await apiService.createOrder({
        'id': 'ord_test_1',
        'orderNumber': 'WB-20261121-9999',
        'userId': 'user_test',
        'createdAt': DateTime.now().toIso8601String(),
        'status': 'Menunggu Pembayaran',
        'paymentMethod': 'Transfer Bank',
        'address': {
          'id': 'addr_test',
          'userId': 'user_test',
          'recipientName': 'Testing',
          'phone': '08123456789',
          'fullAddress': 'Jl. Bunga Melati No. 5',
          'city': 'Jakarta Selatan',
          'district': 'Tebet',
          'latitude': -6.2,
          'longitude': 106.8,
        },
        'subtotal': 50000.0,
        'shippingCost': 5000.0,
        'total': 55000.0,
        'items': [
          {
            'productId': 'p1',
            'name': 'Bayam Hijau',
            'price': 6500.0,
            'unit': 'ikat',
            'quantity': 2,
            'subtotal': 13000.0,
          }
        ],
      });

      expect(order.paymentMethod, 'Transfer Bank');
      expect(order.status, 'Menunggu Pembayaran');

      // Perbarui metode pembayaran ke E-Wallet
      final updated = await apiService.updateOrderPaymentMethod(order.id, 'E-Wallet (GoPay/OVO/ShopeePay)');
      expect(updated.paymentMethod, 'E-Wallet (GoPay/OVO/ShopeePay)');
      expect(updated.id, order.id);
    });

    test('ReminderModel: Serialisasi dengan status isRead dan pesan detail', () {
      final notif = ReminderModel(
        id: 'ord_notif_1',
        userId: 'user_1',
        title: 'Pesanan Berhasil Dibuat (Menunggu Pembayaran)',
        message: 'Pesanan No. WB-20261121-1234 berhasil dibuat. Segera selesaikan pembayaran.',
        scheduledAt: DateTime.now(),
        isActive: true,
        isRead: false,
      );

      final json = notif.toJson();
      expect(json['is_read'], 0);
      expect(json['message'], contains('WB-20261121-1234'));

      final copy = ReminderModel.fromJson(json);
      expect(copy.id, notif.id);
      expect(copy.isRead, isFalse);
      expect(copy.message, notif.message);

      final readCopy = copy.copyWith(isRead: true);
      expect(readCopy.isRead, isTrue);
    });

    test('SQLite Schema & Model: Tabel Users, Orders, dan Order Items', () {
      // 1. Validasi UserModel dengan createdAt
      final user = UserModel(
        id: 'usr_test_1',
        name: 'Ahmad Subagyo',
        email: 'ahmad@example.com',
        username: 'ahmad_s',
        passwordHash: 'hash123',
        phone: '081298765432',
      );
      final userJson = user.toJson();
      expect(userJson['id'], 'usr_test_1');
      expect(userJson['name'], 'Ahmad Subagyo');
      expect(userJson['email'], 'ahmad@example.com');
      expect(userJson['phone'], '081298765432');
      expect(userJson['created_at'], isNotEmpty);

      // 2. Validasi OrderModel dan OrderItemModel terstruktur
      final orderItem = OrderItemModel(
        productId: 'p1',
        name: 'Bayam Hijau',
        price: 6500.0,
        unit: 'ikat',
        quantity: 3,
        subtotal: 19500.0,
      );
      expect(orderItem.subtotal, 19500.0);
      expect(orderItem.quantity, 3);
      final itemJson = orderItem.toJson();
      expect(itemJson['productId'], 'p1');
      expect(itemJson['price'], 6500.0);

      // 3. Validasi OrderModel customerName getter
      final order = OrderModel(
        id: 'ord_test_99',
        orderNumber: 'WB-20261121-8888',
        userId: user.id,
        createdAt: DateTime.now(),
        status: 'Menunggu Pembayaran',
        paymentMethod: 'Transfer Bank',
        address: AddressModel(
          id: 'addr_1',
          userId: user.id,
          recipientName: 'Ahmad Subagyo',
          phone: '081298765432',
          fullAddress: 'Jl. Merdeka No. 10',
          city: 'Jakarta',
          district: 'Gambir',
          latitude: -6.2,
          longitude: 106.8,
        ),
        subtotal: 19500.0,
        shippingCost: 5000.0,
        total: 24500.0,
        items: [orderItem],
      );
      expect(order.customerName, 'Ahmad Subagyo');
      expect(order.items.length, 1);
      expect(order.items.first.productId, 'p1');
    });
  });
}
