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
      sellerLocation: json['sellerLocation']?.toString() ?? 'Jakarta',
      sellerLat: (json['sellerLat'] as num?)?.toDouble() ?? -6.2088,
      sellerLng: (json['sellerLng'] as num?)?.toDouble() ?? 106.8456,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
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
    );
  }
}
