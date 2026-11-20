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
