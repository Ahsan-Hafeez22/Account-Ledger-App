import 'package:account_ledger/features/transaction/domain/entities/transaction_pagination_entity.dart';

class TransactionPaginationModel extends TransactionPaginationEntity {
  const TransactionPaginationModel({
    required super.total,
    required super.page,
    required super.limit,
    required super.totalPages,
    required super.hasNextPage,
  });

  factory TransactionPaginationModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const TransactionPaginationModel(
        total: 0,
        page: 1,
        limit: 10,
        totalPages: 0,
        hasNextPage: false,
      );
    }
    return TransactionPaginationModel(
      total: (json['total'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 10,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
      hasNextPage: json['hasNextPage'] as bool? ?? false,
    );
  }

  TransactionPaginationEntity toEntity() => TransactionPaginationEntity(
    total: total,
    page: page,
    limit: limit,
    totalPages: totalPages,
    hasNextPage: hasNextPage,
  );
}
