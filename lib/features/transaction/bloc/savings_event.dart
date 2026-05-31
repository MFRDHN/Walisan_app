import 'package:equatable/equatable.dart';

abstract class SavingsEvent extends Equatable {
  const SavingsEvent();

  @override
  List<Object> get props => [];
}

class SavingsFetch extends SavingsEvent {}

class SavingsUpdateLimit extends SavingsEvent {
  final int dailyLimit;

  const SavingsUpdateLimit({required this.dailyLimit});

  @override
  List<Object> get props => [dailyLimit];
}

class SavingsTopUp extends SavingsEvent {
  final int amount;
  final String? paymentMethod;

  const SavingsTopUp({required this.amount, this.paymentMethod});

  @override
  List<Object> get props => [amount, paymentMethod ?? ''];
}
