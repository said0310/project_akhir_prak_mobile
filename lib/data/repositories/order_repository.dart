import 'dart:math';
import 'package:intl/intl.dart';
import '../models/order_model.dart';
import '../models/address_model.dart';
import '../models/cart_item_model.dart';
import '../providers/api_service.dart';

class OrderRepository {
  final ApiService apiService;

  OrderRepository({required this.apiService});

  /// Format nomor pesanan unik: WB-YYYYMMDD-XXXX (BR-07)
  static String generateOrderNumber() {
    final now = DateTime.now();
    final dateStr = DateFormat('yyyyMMdd').format(now);
    final randomDigits = (1000 + Random().nextInt(9000)).toString();
    return 'WB-$dateStr-$randomDigits';
  }

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

    // Sesuai BR-08: Jika COD, langsung berstatus 'Diproses'. Jika bukan COD, status awal 'Menunggu Pembayaran'.
    final initialStatus = (paymentMethod.toUpperCase() == 'COD')
        ? 'Diproses'
        : 'Menunggu Pembayaran';

    final orderItems = items
        .map((item) => OrderItemModel(
              productId: item.productId,
              name: item.name,
              price: item.price,
              unit: item.unit,
              quantity: item.quantity,
              subtotal: item.subtotal,
            ))
        .toList();

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

  Future<List<OrderModel>> getOrders(String userId) async {
    return await apiService.getOrders(userId);
  }

  Future<OrderModel> getOrderById(String id) async {
    return await apiService.getOrderById(id);
  }

  Future<OrderModel> updateStatus(String id, String status) async {
    return await apiService.updateOrderStatus(id, status);
  }
}
