import 'package:account_ledger/features/transaction/domain/usecases/verify_pin_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:account_ledger/core/usecase/usecase.dart';
import 'package:account_ledger/features/transaction/domain/entities/transaction_entity.dart';
import 'package:account_ledger/features/transaction/domain/entities/transaction_pagination_entity.dart';
import 'package:account_ledger/features/transaction/domain/usecases/create_transfer_usecase.dart';
import 'package:account_ledger/features/transaction/domain/usecases/get_transactions_usecase.dart';
import 'package:account_ledger/features/transaction/domain/usecases/recover_pending_transfer_usecase.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  TransactionBloc({
    required GetTransactionsUseCase getTransactionsUseCase,
    required CreateTransferUseCase createTransferUseCase,
    required RecoverPendingTransferUseCase recoverPendingTransferUseCase,
    required VerfiyPinUsecase verifyPinUsecase,
  }) : _getTransactionsUseCase = getTransactionsUseCase,
       _createTransferUseCase = createTransferUseCase,
       _recoverPendingTransferUseCase = recoverPendingTransferUseCase,
       _verifyPinUsecase = verifyPinUsecase,
       super(const TransactionInitial()) {
    on<TransactionLoadRequested>(_onLoadRequested);
    on<TransactionLoadMoreRequested>(_onLoadMore);
    on<TransferSubmitted>(_onTransferSubmitted);
    on<TransferWithPinSubmitted>(_onTransferWithPinSubmitted);
    on<TransactionMessageConsumed>(_onMessageConsumed);
    on<VerfiyPinRequested>(_onVerifyPinRequested);
  }

  final GetTransactionsUseCase _getTransactionsUseCase;
  final CreateTransferUseCase _createTransferUseCase;
  final RecoverPendingTransferUseCase _recoverPendingTransferUseCase;
  final VerfiyPinUsecase _verifyPinUsecase;

  Future<void> _onLoadRequested(
    TransactionLoadRequested event,
    Emitter<TransactionState> emit,
  ) async {
    emit(const TransactionLoading());

    String? recoverySuccess;
    await _recoverPendingTransferUseCase(const NoParams()).then((rec) {
      rec.fold((_) {}, (msg) {
        if (msg != null && msg.isNotEmpty) recoverySuccess = msg;
      });
    });

    final page = await _getTransactionsUseCase(
      GetTransactionsParams(page: event.page, limit: event.limit),
    );
    page.fold(
      (failure) => emit(TransactionFailure(failure.message)),
      (data) => emit(
        TransactionLoaded(
          transactions: data.transactions,
          pagination: data.pagination,
          successMessage: recoverySuccess,
        ),
      ),
    );
  }

  Future<void> _onVerifyPinRequested(
    VerfiyPinRequested event,
    Emitter<TransactionState> emit,
  ) async {
    // Keep for backward compatibility if other UI triggers it.
    // We don't want to wipe the transactions screen state.
    final current = state;
    if (current is! TransactionLoaded) return;
    emit(current.copyWith(isSending: true, clearError: true, clearSuccess: true));
    final result = await _verifyPinUsecase(VerifyPinParams(pin: event.pin));
    result.fold(
      (failure) => emit(
        current.copyWith(
          isSending: false,
          errorMessage: failure.message,
          errorCode: failure.code,
        ),
      ),
      (_) => emit(
        current.copyWith(isSending: false, successMessage: 'PIN verified.'),
      ),
    );
  }

  Future<void> _onLoadMore(
    TransactionLoadMoreRequested event,
    Emitter<TransactionState> emit,
  ) async {
    final current = state;
    if (current is! TransactionLoaded) return;
    if (!current.pagination.hasNextPage || current.isLoadingMore) return;

    emit(current.copyWith(isLoadingMore: true, clearError: true));

    final nextPage = current.pagination.page + 1;
    final result = await _getTransactionsUseCase(
      GetTransactionsParams(page: nextPage, limit: current.pagination.limit),
    );

    result.fold(
      (failure) => emit(
        current.copyWith(
          isLoadingMore: false,
          errorMessage: failure.message,
          errorCode: failure.code,
        ),
      ),
      (data) => emit(
        current.copyWith(
          isLoadingMore: false,
          transactions: [...current.transactions, ...data.transactions],
          pagination: data.pagination,
        ),
      ),
    );
  }

  Future<void> _onTransferSubmitted(
    TransferSubmitted event,
    Emitter<TransactionState> emit,
  ) async {
    final current = state;
    if (current is! TransactionLoaded) return;

    final amount = double.tryParse(event.amount.trim());
    if (amount == null || amount <= 0) {
      emit(
        current.copyWith(
          errorMessage: 'Enter a valid amount.',
          clearSuccess: true,
        ),
      );
      return;
    }
    if (event.toAccount.trim().isEmpty) {
      emit(
        current.copyWith(
          errorMessage: 'Recipient account number is required.',
          clearSuccess: true,
        ),
      );
      return;
    }

    emit(
      current.copyWith(isSending: true, clearError: true, clearSuccess: true),
    );

    final desc = event.description?.trim();
    final outcome = await _createTransferUseCase(
      CreateTransferParams(
        toAccount: event.toAccount.trim(),
        amount: amount,
        description: (desc == null || desc.isEmpty) ? null : desc,
      ),
    );

    await outcome.fold(
      (failure) async {
        emit(
          current.copyWith(
            isSending: false,
            errorMessage: failure.message,
            errorCode: failure.code,
          ),
        );
      },
      (_) async {
        final refreshed = await _getTransactionsUseCase(
          GetTransactionsParams(
            page: 1,
            limit: current.pagination.limit,
          ),
        );
        refreshed.fold(
          (failure) => emit(
            current.copyWith(
              isSending: false,
              successMessage: 'Transfer completed successfully.',
              errorMessage: failure.message,
              errorCode: failure.code,
            ),
          ),
          (data) => emit(
            TransactionLoaded(
              transactions: data.transactions,
              pagination: data.pagination,
              successMessage: 'Transfer completed successfully.',
            ),
          ),
        );
      },
    );
  }

  Future<void> _onTransferWithPinSubmitted(
    TransferWithPinSubmitted event,
    Emitter<TransactionState> emit,
  ) async {
    final current = state;
    if (current is! TransactionLoaded) return;

    final pin = event.pin.trim();
    if (pin.length != 4) {
      emit(
        current.copyWith(
          errorMessage: 'Enter a valid 4-digit PIN.',
          clearSuccess: true,
        ),
      );
      return;
    }

    emit(
      current.copyWith(isSending: true, clearError: true, clearSuccess: true),
    );

    final verify = await _verifyPinUsecase(VerifyPinParams(pin: pin));
    final verified = await verify.fold((failure) async {
      emit(
        current.copyWith(
          isSending: false,
          errorMessage: failure.message,
          errorCode: failure.code,
        ),
      );
      return false;
    }, (_) async {
      return true;
    });
    if (!verified) return;

    // Proceed with the actual transfer.
    final outcome = await _createTransferUseCase(
      CreateTransferParams(
        toAccount: event.toAccount.trim(),
        amount: double.tryParse(event.amount.trim()) ?? 0,
        description: event.description,
      ),
    );

    await outcome.fold(
      (failure) async => emit(
        current.copyWith(
          isSending: false,
          errorMessage: failure.message,
          errorCode: failure.code,
        ),
      ),
      (_) async {
        final refreshed = await _getTransactionsUseCase(
          GetTransactionsParams(page: 1, limit: current.pagination.limit),
        );
        refreshed.fold(
          (failure) => emit(
            current.copyWith(
              isSending: false,
              successMessage: 'Transfer completed successfully.',
              errorMessage: failure.message,
              errorCode: failure.code,
            ),
          ),
          (data) => emit(
            TransactionLoaded(
              transactions: data.transactions,
              pagination: data.pagination,
              successMessage: 'Transfer completed successfully.',
            ),
          ),
        );
      },
    );
  }

  void _onMessageConsumed(
    TransactionMessageConsumed event,
    Emitter<TransactionState> emit,
  ) {
    final current = state;
    if (current is TransactionLoaded) {
      if (current.errorMessage != null) {
        emit(current.copyWith(clearError: true));
      } else if (current.successMessage != null) {
        emit(current.copyWith(clearSuccess: true));
      }
    }
  }
}
