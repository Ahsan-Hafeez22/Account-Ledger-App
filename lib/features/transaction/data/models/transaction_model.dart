import 'package:account_ledger/features/transaction/data/models/transaction_party_model.dart';
import 'package:account_ledger/features/transaction/domain/entities/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    super.fromParty,
    super.toParty,
    required super.amount,
    super.idempotencyKey,
    super.description,
    required super.status,
    super.direction,
    super.createdAt,
    super.updatedAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final fromRaw = json['fromAccount'];
    final toRaw = json['toAccount'];
    Map<String, dynamic>? fromMap;
    Map<String, dynamic>? toMap;
    if (fromRaw is Map<String, dynamic>) {
      fromMap = fromRaw;
    } else if (fromRaw is Map) {
      fromMap = Map<String, dynamic>.from(fromRaw);
    }
    if (toRaw is Map<String, dynamic>) {
      toMap = toRaw;
    } else if (toRaw is Map) {
      toMap = Map<String, dynamic>.from(toRaw);
    }

    return TransactionModel(
      id: _asTxnId(json['_id']),
      fromParty: fromMap != null
          ? TransactionPartyModel.fromJson(fromMap)
          : null,
      toParty: toMap != null ? TransactionPartyModel.fromJson(toMap) : null,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      idempotencyKey: json['idempotencyKey'] as String?,
      description: json['description'] as String?,
      status: json['status'] as String? ?? '',
      direction: json['direction'] as String?,
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  static String _asTxnId(dynamic raw) {
    if (raw is String) return raw;
    if (raw is Map && raw[r'$oid'] is String) return raw[r'$oid'] as String;
    return raw?.toString() ?? '';
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  TransactionEntity toEntity() => TransactionEntity(
    id: id,
    fromParty: fromParty,
    toParty: toParty,
    amount: amount,
    idempotencyKey: idempotencyKey,
    description: description,
    status: status,
    direction: direction,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
