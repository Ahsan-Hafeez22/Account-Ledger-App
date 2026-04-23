import 'package:account_ledger/features/beneficiary/domain/entities/beneficiary_entity.dart';

class BeneficiaryModel {
  final String id;
  final String userId;
  final String nickname;
  final String accountTitle;
  final String accountNumber;
  final String userName;
  final String email;
  final String? avatarUrl;

  const BeneficiaryModel({
    required this.id,
    required this.userId,
    required this.nickname,
    required this.accountTitle,
    required this.accountNumber,
    required this.userName,
    required this.email,
    required this.avatarUrl,
  });

  factory BeneficiaryModel.fromJson(Map<String, dynamic> json) {
    String readUserId() {
      final direct = (json['userId'] ?? json['user_id'] ?? '').toString();
      if (direct.isNotEmpty) return direct;
      final user = json['user'];
      if (user is Map) {
        final id = (user['_id'] ?? user['id'] ?? '').toString();
        if (id.isNotEmpty) return id;
      }
      final receiver = json['receiver'];
      if (receiver is Map) {
        final id = (receiver['_id'] ?? receiver['id'] ?? '').toString();
        if (id.isNotEmpty) return id;
      }
      return '';
    }

    return BeneficiaryModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      userId: readUserId(),
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
        userId: userId,
        nickname: nickname,
        accountTitle: accountTitle,
        accountNumber: accountNumber,
        userName: userName,
        email: email,
        avatarUrl: avatarUrl,
      );
}

