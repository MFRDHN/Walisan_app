import 'package:equatable/equatable.dart';

abstract class BillState extends Equatable {
  const BillState();

  @override
  List<Object?> get props => [];
}

class BillInitial extends BillState {}

class BillLoading extends BillState {}

class BillLoaded extends BillState {
  final List<dynamic> bills;
  final String studentName;
  final String studentVa;
  final String studentBank;

  const BillLoaded({
    required this.bills,
    this.studentName = '',
    this.studentVa = '',
    this.studentBank = 'BCA',
  });

  @override
  List<Object?> get props => [bills, studentName, studentVa, studentBank];
}

class BillPayLoading extends BillState {
  final int billId;

  const BillPayLoading({required this.billId});

  @override
  List<Object> get props => [billId];
}

class BillPayReady extends BillState {
  final String redirectUrl;
  final String orderId;

  const BillPayReady({required this.redirectUrl, required this.orderId});

  @override
  List<Object> get props => [redirectUrl, orderId];
}

class BillPaySuccess extends BillState {}

class BillFailure extends BillState {
  final String error;

  const BillFailure({required this.error});

  @override
  List<Object> get props => [error];
}
