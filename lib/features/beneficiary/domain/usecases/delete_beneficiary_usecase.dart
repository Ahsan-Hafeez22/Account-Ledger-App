import 'package:account_ledger/features/beneficiary/domain/repositories/beneficiary_repository.dart';

class DeleteBeneficiaryUseCase {
  final BeneficiaryRepository _repo;
  const DeleteBeneficiaryUseCase(this._repo);

  Future<void> call(String id) => _repo.deleteBeneficiary(id);
}

