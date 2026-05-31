import 'package:equatable/equatable.dart';

abstract class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object?> get props => [];
}

class HistoryInitial extends HistoryState {}

class HistoryLoading extends HistoryState {}

class HistoryLoaded extends HistoryState {
  final List<dynamic> payments;
  final int totalAmount;

  const HistoryLoaded({required this.payments, this.totalAmount = 0});

  @override
  List<Object?> get props => [payments, totalAmount];
}

class HistoryFailure extends HistoryState {
  final String error;

  const HistoryFailure({required this.error});

  @override
  List<Object> get props => [error];
}
