import 'package:account_ledger/features/transaction/domain/entities/transaction_party_entity.dart';

class TransactionPartyModel extends TransactionPartyEntity {
  const TransactionPartyModel({
    required super.id,
    required super.accountNumber,
    required super.accountTitle,
    super.currency,
    super.status,
    super.userName,
    super.userEmail,
  });

  factory TransactionPartyModel.fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) {
      return const TransactionPartyModel(
        id: '',
        accountNumber: '',
        accountTitle: '',
      );
    }
    final userRaw = json['user'];
    Map<String, dynamic>? userMap;
    if (userRaw is Map<String, dynamic>) {
      userMap = userRaw;
    } else if (userRaw is Map) {
      userMap = Map<String, dynamic>.from(userRaw);
    }

    return TransactionPartyModel(
      id: _asId(json['_id']),
      accountNumber: json['accountNumber'] as String? ?? '',
      accountTitle: json['accountTitle'] as String? ?? '',
      currency: json['currency'] as String?,
      status: json['status'] as String?,
      userName: userMap?['name'] as String?,
      userEmail: userMap?['email'] as String?,
    );
  }

  static String _asId(dynamic raw) {
    if (raw is String) return raw;
    if (raw is Map && raw[r'$oid'] is String) return raw[r'$oid'] as String;
    return raw?.toString() ?? '';
  }

  TransactionPartyEntity toEntity() => TransactionPartyEntity(
    id: id,
    accountNumber: accountNumber,
    accountTitle: accountTitle,
    currency: currency,
    status: status,
    userName: userName,
    userEmail: userEmail,
  );
}
