class ReminderModel {
  final String id;
  final String userId;
  final String title;
  final DateTime scheduledAt;
  bool isActive;

  ReminderModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.scheduledAt,
    this.isActive = true,
  });

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      scheduledAt: json['scheduledAt'] != null
          ? DateTime.tryParse(json['scheduledAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'scheduledAt': scheduledAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  ReminderModel copyWith({
    String? id,
    String? userId,
    String? title,
    DateTime? scheduledAt,
    bool? isActive,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
