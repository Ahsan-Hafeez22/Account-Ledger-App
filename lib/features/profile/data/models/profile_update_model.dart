class ProfileUpdateModel {
  final String? name;
  final String? phone;
  final String? avatarUrl;
  final DateTime? dateOfBirth;
  final String? country;
  final String? defaultCurrency;

  const ProfileUpdateModel({
    required this.name,
    required this.phone,
    required this.avatarUrl,
    required this.dateOfBirth,
    required this.country,
    required this.defaultCurrency,
  });

  factory ProfileUpdateModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
      return null;
    }

    return ProfileUpdateModel(
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      avatarUrl: (json['avatar'] ?? json['avatarUrl'] ?? json['avatar_url']) as String?,
      dateOfBirth: parseDate(json['dateOfBirth'] ?? json['date_of_birth']),
      country: json['country'] as String?,
      defaultCurrency: json['defaultCurrency'] as String?,
    );
  }
}

