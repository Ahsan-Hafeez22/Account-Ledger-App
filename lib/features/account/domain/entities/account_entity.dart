import 'package:equatable/equatable.dart';

class AccountEntity extends Equatable {
  final String id;
  final String userId;
  final String accountTitle;
  final String currency;
  final String status;
  final String accountNumber;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AccountEntity({
    required this.id,
    required this.userId,
    required this.accountTitle,
    required this.currency,
    required this.status,
    required this.accountNumber,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    accountTitle,
    currency,
    status,
    accountNumber,
    createdAt,
    updatedAt,
  ];
}
