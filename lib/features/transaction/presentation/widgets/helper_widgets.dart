import 'package:account_ledger/features/transaction/domain/entities/transaction_entity.dart';
import 'package:account_ledger/features/transaction/domain/entities/transaction_party_entity.dart';
import 'package:intl/intl.dart';

String counterpartyLabel(TransactionEntity t) {
  final dir = t.direction?.toUpperCase();
  TransactionPartyEntity? other;
  if (dir == 'DEBIT') {
    other = t.toParty;
  } else if (dir == 'CREDIT') {
    other = t.fromParty;
  } else {
    other = t.toParty ?? t.fromParty;
  }
  if (other == null) return '—';
  final name = other.userName?.trim();
  if (name != null && name.isNotEmpty) return name;
  return other.accountTitle.isNotEmpty
      ? other.accountTitle
      : other.accountNumber;
}

String formatWhen(DateTime? d) {
  if (d == null) return '—';
  return DateFormat.yMMMd().add_jm().format(d.toLocal());
}
