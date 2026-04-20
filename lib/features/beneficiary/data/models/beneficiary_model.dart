import 'package:account_ledger/features/beneficiary/domain/entities/beneficiary_entity.dart';

class BeneficiaryModel {
  final String id;
  final String nickname;
  final String accountTitle;
  final String accountNumber;
  final String userName;
  final String email;
  final String? avatarUrl;

  const BeneficiaryModel({
    required this.id,
    required this.nickname,
    required this.accountTitle,
    required this.accountNumber,
    required this.userName,
    required this.email,
    required this.avatarUrl,
  });

  factory BeneficiaryModel.fromJson(Map<String, dynamic> json) {
    return BeneficiaryModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      nickname: (json['nickname'] ?? '').toString(),
      accountTitle: (json['account_title'] ?? json['accountTitle'] ?? '').toString(),
      accountNumber:
          (json['account_number'] ?? json['accountNumber'] ?? '').toString(),
      userName: (json['user_name'] ?? json['userName'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      avatarUrl: (json['avatar'] ?? json['avatarUrl'] ?? json['avatar_url'])
          ?.toString(),
    );
  }

  BeneficiaryEntity toEntity() => BeneficiaryEntity(
        id: id,
        nickname: nickname,
        accountTitle: accountTitle,
        accountNumber: accountNumber,
        userName: userName,
        email: email,
        avatarUrl: avatarUrl,
      );
}

