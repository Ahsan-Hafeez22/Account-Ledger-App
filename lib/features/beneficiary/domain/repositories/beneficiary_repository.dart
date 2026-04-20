import 'package:account_ledger/features/beneficiary/domain/entities/beneficiary_entity.dart';

abstract class BeneficiaryRepository {
  Future<List<BeneficiaryEntity>> getBeneficiaries();
  Future<void> addBeneficiary({
    required String accountNumber,
    required String nickname,
  });
  Future<void> deleteBeneficiary(String id);
}

