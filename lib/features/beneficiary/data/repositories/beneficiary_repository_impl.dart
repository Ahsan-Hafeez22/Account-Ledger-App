import 'package:account_ledger/features/beneficiary/data/datasources/beneficiary_remote_datasource.dart';
import 'package:account_ledger/features/beneficiary/domain/entities/beneficiary_entity.dart';
import 'package:account_ledger/features/beneficiary/domain/repositories/beneficiary_repository.dart';

class BeneficiaryRepositoryImpl implements BeneficiaryRepository {
  final BeneficiaryRemoteDatasource _remote;

  const BeneficiaryRepositoryImpl({required BeneficiaryRemoteDatasource remote})
      : _remote = remote;

  @override
  Future<List<BeneficiaryEntity>> getBeneficiaries() async {
    final models = await _remote.getBeneficiaries();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> addBeneficiary({
    required String accountNumber,
    required String nickname,
  }) =>
      _remote.addBeneficiary(accountNumber: accountNumber, nickname: nickname);

  @override
  Future<void> deleteBeneficiary(String id) => _remote.deleteBeneficiary(id);
}

