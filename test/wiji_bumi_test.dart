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
  });
}
