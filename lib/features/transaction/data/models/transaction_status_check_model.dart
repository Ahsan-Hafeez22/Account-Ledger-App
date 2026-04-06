import 'package:account_ledger/features/transaction/domain/entities/transaction_status_check_entity.dart';

class TransactionStatusCheckModel extends TransactionStatusCheckEntity {
  const TransactionStatusCheckModel({
    required super.transactionId,
    required super.status,
    required super.amount,
    super.createdAt,
  });

  factory TransactionStatusCheckModel.fromJson(Map<String, dynamic> json) {
    return TransactionStatusCheckModel(
      transactionId: json['transactionId'] as String? ?? '',
      status: json['status'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      createdAt: _parseDate(json['createdAt']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  TransactionStatusCheckEntity toEntity() => TransactionStatusCheckEntity(
    transactionId: transactionId,
    status: status,
    amount: amount,
    createdAt: createdAt,
  );
}
