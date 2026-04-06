part of 'transaction_bloc.dart';

sealed class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object?> get props => [];
}

class TransactionInitial extends TransactionState {
  const TransactionInitial();
}

class TransactionLoading extends TransactionState {
  const TransactionLoading();
}

class TransactionFailure extends TransactionState {
  final String message;

  const TransactionFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class TransactionLoaded extends TransactionState {
  final List<TransactionEntity> transactions;
  final TransactionPaginationEntity pagination;
  final bool isLoadingMore;
  final bool isSending;
  final String? errorMessage;
  final String? successMessage;

  const TransactionLoaded({
    required this.transactions,
    required this.pagination,
    this.isLoadingMore = false,
    this.isSending = false,
    this.errorMessage,
    this.successMessage,
  });

  TransactionLoaded copyWith({
    List<TransactionEntity>? transactions,
    TransactionPaginationEntity? pagination,
    bool? isLoadingMore,
    bool? isSending,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return TransactionLoaded(
      transactions: transactions ?? this.transactions,
      pagination: pagination ?? this.pagination,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isSending: isSending ?? this.isSending,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
    transactions,
    pagination,
    isLoadingMore,
    isSending,
    errorMessage,
    successMessage,
  ];
}
