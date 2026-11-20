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
