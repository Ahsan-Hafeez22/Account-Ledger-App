import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:account_ledger/features/transaction/domain/entities/transaction_entity.dart';
import 'package:account_ledger/features/transaction/domain/usecases/get_transaction_detail_usecase.dart';

part 'transaction_detail_event.dart';
part 'transaction_detail_state.dart';

class TransactionDetailBloc
    extends Bloc<TransactionDetailEvent, TransactionDetailState> {
  TransactionDetailBloc({required GetTransactionDetailUseCase getTransactionDetail})
    : _getTransactionDetail = getTransactionDetail,
      super(const TransactionDetailInitial()) {
    on<TransactionDetailLoadRequested>(_onLoad);
  }

  final GetTransactionDetailUseCase _getTransactionDetail;

  Future<void> _onLoad(
    TransactionDetailLoadRequested event,
    Emitter<TransactionDetailState> emit,
  ) async {
    emit(const TransactionDetailLoading());
    final result = await _getTransactionDetail(
      GetTransactionDetailParams(event.transactionId),
    );
    result.fold(
      (f) => emit(TransactionDetailFailure(f.message)),
      (t) => emit(TransactionDetailLoaded(t)),
    );
  }
}
