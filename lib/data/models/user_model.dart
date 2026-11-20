class UserModel {
  final String id;
  final String name;
  final String email;
  final String username;
  final String passwordHash;
  final String phone;
  final String photoUrl;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.username,
    required this.passwordHash,
    this.phone = '',
    this.photoUrl = '',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      passwordHash: json['passwordHash']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      photoUrl: json['photoUrl']?.toString() ?? '',
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
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      username: username ?? this.username,
      passwordHash: passwordHash ?? this.passwordHash,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}
