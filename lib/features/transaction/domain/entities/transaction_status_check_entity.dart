import 'package:equatable/equatable.dart';

class TransactionStatusCheckEntity extends Equatable {
  final String transactionId;
  final String status;
  final double amount;
  final DateTime? createdAt;

  const TransactionStatusCheckEntity({
    required this.transactionId,
    required this.status,
    required this.amount,
    this.createdAt,
  });

  @override
  List<Object?> get props => [transactionId, status, amount, createdAt];
}
