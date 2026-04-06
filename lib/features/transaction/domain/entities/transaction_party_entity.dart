import 'package:equatable/equatable.dart';

class TransactionPartyEntity extends Equatable {
  final String id;
  final String accountNumber;
  final String accountTitle;
  final String? currency;
  final String? status;
  final String? userName;
  final String? userEmail;

  const TransactionPartyEntity({
    required this.id,
    required this.accountNumber,
    required this.accountTitle,
    this.currency,
    this.status,
    this.userName,
    this.userEmail,
  });

  @override
  List<Object?> get props => [
    id,
    accountNumber,
    accountTitle,
    currency,
    status,
    userName,
    userEmail,
  ];
}
