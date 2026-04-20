import 'package:account_ledger/features/beneficiary/domain/entities/beneficiary_entity.dart';
import 'package:account_ledger/features/beneficiary/domain/repositories/beneficiary_repository.dart';

class GetBeneficiariesUseCase {
  final BeneficiaryRepository _repo;
  const GetBeneficiariesUseCase(this._repo);

  Future<List<BeneficiaryEntity>> call() => _repo.getBeneficiaries();
}

