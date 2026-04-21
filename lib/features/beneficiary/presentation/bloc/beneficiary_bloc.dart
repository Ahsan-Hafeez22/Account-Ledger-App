import 'package:account_ledger/features/beneficiary/domain/entities/beneficiary_entity.dart';
import 'package:account_ledger/features/beneficiary/domain/usecases/add_beneficiary_usecase.dart';
import 'package:account_ledger/features/beneficiary/domain/usecases/delete_beneficiary_usecase.dart';
import 'package:account_ledger/features/beneficiary/domain/usecases/get_beneficiaries_usecase.dart';
import 'package:account_ledger/core/error/exceptions.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'beneficiary_event.dart';
part 'beneficiary_state.dart';

class BeneficiaryBloc extends Bloc<BeneficiaryEvent, BeneficiaryState> {
  final GetBeneficiariesUseCase _get;
  final AddBeneficiaryUseCase _add;
  final DeleteBeneficiaryUseCase _delete;

  BeneficiaryBloc({
    required GetBeneficiariesUseCase getBeneficiaries,
    required AddBeneficiaryUseCase addBeneficiary,
    required DeleteBeneficiaryUseCase deleteBeneficiary,
  }) : _get = getBeneficiaries,
       _add = addBeneficiary,
       _delete = deleteBeneficiary,
       super(const BeneficiaryState.initial()) {
    on<BeneficiariesLoadRequested>(_onLoad);
    on<BeneficiariesRefreshRequested>(_onRefresh);
    on<BeneficiariesCleared>((event, emit) {
      emit(const BeneficiaryState.initial());
    });
    on<BeneficiaryAddRequested>(_onAdd);
    on<BeneficiaryDeleteRequested>(_onDelete);
    on<BeneficiaryMessageConsumed>((event, emit) {
      emit(state.copyWith(message: null, errorMessage: null));
    });
  }

  Future<void> _onLoad(
    BeneficiariesLoadRequested event,
    Emitter<BeneficiaryState> emit,
  ) async {
    // Clear old cached items while loading (important on account switch).
    emit(
      state.copyWith(
        loading: true,
        submitting: false,
        items: const [],
        busyIds: const {},
        message: null,
        errorMessage: null,
      ),
    );
    try {
      final items = await _get();
      emit(state.copyWith(loading: false, items: items));
    } on ServerException catch (e) {
      emit(state.copyWith(loading: false, errorMessage: e.message));
    } on NetworkException catch (e) {
      emit(state.copyWith(loading: false, errorMessage: e.message));
    } catch (_) {
      emit(
        state.copyWith(
          loading: false,
          errorMessage: 'Failed to load beneficiaries',
        ),
      );
    }
  }

  Future<void> _onRefresh(
    BeneficiariesRefreshRequested event,
    Emitter<BeneficiaryState> emit,
  ) async {
    try {
      final items = await _get();
      emit(state.copyWith(items: items));
    } on ServerException catch (e) {
      emit(state.copyWith(errorMessage: e.message));
    } on NetworkException catch (e) {
      emit(state.copyWith(errorMessage: e.message));
    } catch (_) {
      emit(state.copyWith(errorMessage: 'Refresh failed'));
    }
  }

  Future<void> _onAdd(
    BeneficiaryAddRequested event,
    Emitter<BeneficiaryState> emit,
  ) async {
    if (state.submitting) return;
    emit(state.copyWith(submitting: true, message: null, errorMessage: null));
    try {
      await _add(accountNumber: event.accountNumber, nickname: event.nickname);
      final items = await _get();
      emit(
        state.copyWith(
          submitting: false,
          items: items,
          message: 'Beneficiary added',
        ),
      );
    } on ServerException catch (e) {
      emit(state.copyWith(submitting: false, errorMessage: e.message));
    } on NetworkException catch (e) {
      emit(state.copyWith(submitting: false, errorMessage: e.message));
    } catch (_) {
      emit(
        state.copyWith(
          submitting: false,
          errorMessage: 'Failed to add beneficiary',
        ),
      );
    }
  }

  Future<void> _onDelete(
    BeneficiaryDeleteRequested event,
    Emitter<BeneficiaryState> emit,
  ) async {
    if (state.busyIds.contains(event.id)) return;
    final before = state.items;
    emit(
      state.copyWith(
        items: state.items.where((e) => e.id != event.id).toList(),
        busyIds: {...state.busyIds, event.id},
      ),
    );
    try {
      await _delete(event.id);
      emit(state.copyWith(message: 'Beneficiary deleted'));
    } on ServerException catch (e) {
      emit(state.copyWith(items: before, errorMessage: e.message));
    } on NetworkException catch (e) {
      emit(state.copyWith(items: before, errorMessage: e.message));
    } catch (_) {
      emit(
        state.copyWith(
          items: before,
          errorMessage: 'Failed to delete beneficiary',
        ),
      );
    } finally {
      final nextBusy = {...state.busyIds}..remove(event.id);
      emit(state.copyWith(busyIds: nextBusy));
    }
  }
}
