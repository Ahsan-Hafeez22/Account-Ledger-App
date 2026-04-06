import 'package:account_ledger/features/transaction/domain/entities/transaction_party_entity.dart';
import 'package:equatable/equatable.dart';

class TransactionEntity extends Equatable {
  final String id;
  final TransactionPartyEntity? fromParty;
  final TransactionPartyEntity? toParty;
  final double amount;
  final String? idempotencyKey;
  final String? description;
  final String status;
  final String? direction;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TransactionEntity({
    required this.id,
    this.fromParty,
    this.toParty,
    required this.amount,
    this.idempotencyKey,
    this.description,
    required this.status,
    this.direction,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    fromParty,
    toParty,
    amount,
    idempotencyKey,
    description,
    status,
    direction,
    createdAt,
    updatedAt,
  ];
}
