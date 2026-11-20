import 'address_model.dart';

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
