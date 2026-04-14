class AppNotificationModel {
  final String id;
  final String type;
  final String title;
  final String body;
  final String? imageUrl;
  final Map<String, dynamic> data;
  final DateTime? readAt;
  final DateTime createdAt;

  const AppNotificationModel({
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

  AppNotificationModel copyWith({
    DateTime? readAt,
  }) {
    return AppNotificationModel(
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

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    Map<String, dynamic> dataMap = const {};
    if (rawData is Map<String, dynamic>) {
      dataMap = rawData;
    } else if (rawData is Map) {
      dataMap = Map<String, dynamic>.from(rawData);
    }

    DateTime? parseDate(dynamic v) {
      if (v is String && v.isNotEmpty) {
        return DateTime.tryParse(v);
      }
      return null;
    }

    return AppNotificationModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      body: (json['body'] ?? '').toString(),
      imageUrl: json['imageUrl'] as String?,
      data: dataMap,
      readAt: parseDate(json['readAt']),
      createdAt: parseDate(json['createdAt']) ?? DateTime.now(),
    );
  }
}

