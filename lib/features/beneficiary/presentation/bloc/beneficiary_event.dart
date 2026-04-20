part of 'beneficiary_bloc.dart';

sealed class BeneficiaryEvent extends Equatable {
  const BeneficiaryEvent();

  @override
  List<Object?> get props => [];
}

final class BeneficiariesLoadRequested extends BeneficiaryEvent {
  const BeneficiariesLoadRequested();
}

final class BeneficiariesRefreshRequested extends BeneficiaryEvent {
  const BeneficiariesRefreshRequested();
}

final class BeneficiaryAddRequested extends BeneficiaryEvent {
  final String accountNumber;
  final String nickname;

  const BeneficiaryAddRequested({
    required this.accountNumber,
    required this.nickname,
  });

  @override
  List<Object?> get props => [accountNumber, nickname];
}

final class BeneficiaryDeleteRequested extends BeneficiaryEvent {
  final String id;
  const BeneficiaryDeleteRequested(this.id);

  @override
  List<Object?> get props => [id];
}

final class BeneficiaryMessageConsumed extends BeneficiaryEvent {
  const BeneficiaryMessageConsumed();
}

