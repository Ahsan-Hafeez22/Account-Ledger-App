import 'package:account_ledger/features/beneficiary/domain/repositories/beneficiary_repository.dart';

class AddBeneficiaryUseCase {
  final BeneficiaryRepository _repo;
  const AddBeneficiaryUseCase(this._repo);

  Future<void> call({
    required String accountNumber,
    required String nickname,
  }) =>
      _repo.addBeneficiary(accountNumber: accountNumber, nickname: nickname);
}

