import 'package:equatable/equatable.dart';

class BeneficiaryEntity extends Equatable {
  final String id;
  /// The actual user id used by chat socket (matches backend `socket.user._id`).
  final String userId;
  final String nickname;
  final String accountTitle;
  final String accountNumber;
  final String userName;
  final String email;
  final String? avatarUrl;

  const BeneficiaryEntity({
    required this.id,
    required this.userId,
    required this.nickname,
    required this.accountTitle,
    required this.accountNumber,
    required this.userName,
    required this.email,
    required this.avatarUrl,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        nickname,
        accountTitle,
        accountNumber,
        userName,
        email,
        avatarUrl,
      ];
}

