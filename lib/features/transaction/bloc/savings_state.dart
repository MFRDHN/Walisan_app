import 'package:equatable/equatable.dart';
import '../../../core/models/savings_model.dart';

abstract class SavingsState extends Equatable {
  const SavingsState();

  @override
  List<Object?> get props => [];
}

class SavingsInitial extends SavingsState {}

class SavingsLoading extends SavingsState {}

class SavingsLoaded extends SavingsState {
  final SavingsData? data;
  final List<SavingsTransaction> history;
  final int monthlyIncome;
  final int monthlyExpense;

  const SavingsLoaded({
    this.data,
    required this.history,
    this.monthlyIncome = 0,
    this.monthlyExpense = 0,
  });

  @override
  List<Object?> get props =>
      [data, history, monthlyIncome, monthlyExpense];
}

class SavingsLimitUpdating extends SavingsState {}

class SavingsFailure extends SavingsState {
  final String error;

  const SavingsFailure({required this.error});

  @override
  List<Object> get props => [error];
}
