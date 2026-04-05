import 'package:account_ledger/features/account/domain/entities/account_entity.dart';

class AccountModel extends AccountEntity {
  const AccountModel({
    required super.id,
    required super.userId,
    required super.accountTitle,
    required super.currency,
    required super.status,
    required super.accountNumber,
    super.createdAt,
    super.updatedAt,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    final userRaw = json['user'];
    final userId = userRaw is String
        ? userRaw
        : userRaw?.toString() ?? '';

    return AccountModel(
      id: json['_id'] as String? ?? '',
      userId: userId,
      accountTitle: json['accountTitle'] as String? ?? '',
      currency: json['currency'] as String? ?? '',
      status: json['status'] as String? ?? '',
      accountNumber: json['accountNumber'] as String? ?? '',
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  AccountEntity toEntity() => AccountEntity(
    id: id,
    userId: userId,
    accountTitle: accountTitle,
    currency: currency,
    status: status,
    accountNumber: accountNumber,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
