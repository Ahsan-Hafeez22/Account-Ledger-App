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
  /// Populated for server failures (e.g. `verify-pin-failed-403`).
  final String? errorCode;
  final String? successMessage;

  const TransactionLoaded({
    required this.transactions,
    required this.pagination,
    this.isLoadingMore = false,
    this.isSending = false,
    this.errorMessage,
    this.errorCode,
    this.successMessage,
  });

  TransactionLoaded copyWith({
    List<TransactionEntity>? transactions,
    TransactionPaginationEntity? pagination,
    bool? isLoadingMore,
    bool? isSending,
    String? errorMessage,
    String? errorCode,
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
      errorCode: clearError ? null : (errorCode ?? this.errorCode),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
    transactions,
    pagination,
    isLoadingMore,
    isSending,
    errorMessage,
    errorCode,
    successMessage,
  ];
}
