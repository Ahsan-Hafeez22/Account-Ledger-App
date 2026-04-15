class AppNotificationEntity {
  final String id;
  final String type;
  final String title;
  final String body;
  final String? imageUrl;
  final Map<String, dynamic> data;
  final DateTime? readAt;
  final DateTime createdAt;

  const AppNotificationEntity({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.imageUrl,
    required this.data,
    required this.readAt,
    required this.createdAt,
  });

  bool get isRead => readAt != null;

  AppNotificationEntity copyWith({
    DateTime? readAt,
  }) {
    return AppNotificationEntity(
      id: id,
      type: type,
      title: title,
      body: body,
      imageUrl: imageUrl,
      data: data,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt,
    );
  }
}

