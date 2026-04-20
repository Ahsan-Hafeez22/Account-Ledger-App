part of 'beneficiary_bloc.dart';

class BeneficiaryState extends Equatable {
  final bool loading;
  final bool submitting;
  final List<BeneficiaryEntity> items;
  final String? message;
  final String? errorMessage;
  final Set<String> busyIds;

  const BeneficiaryState({
    required this.loading,
    required this.submitting,
    required this.items,
    required this.message,
    required this.errorMessage,
    required this.busyIds,
  });

  const BeneficiaryState.initial()
      : loading = true,
        submitting = false,
        items = const [],
        message = null,
        errorMessage = null,
        busyIds = const {};

  BeneficiaryState copyWith({
    bool? loading,
    bool? submitting,
    List<BeneficiaryEntity>? items,
    String? message,
    String? errorMessage,
    Set<String>? busyIds,
  }) {
    return BeneficiaryState(
      loading: loading ?? this.loading,
      submitting: submitting ?? this.submitting,
      items: items ?? this.items,
      message: message,
      errorMessage: errorMessage,
      busyIds: busyIds ?? this.busyIds,
    );
  }

  @override
  List<Object?> get props => [loading, submitting, items, message, errorMessage, busyIds];
}

