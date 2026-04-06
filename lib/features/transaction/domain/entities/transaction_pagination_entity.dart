import 'package:equatable/equatable.dart';

class TransactionPaginationEntity extends Equatable {
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final bool hasNextPage;

  const TransactionPaginationEntity({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.hasNextPage,
  });

  @override
  List<Object?> get props => [total, page, limit, totalPages, hasNextPage];
}
