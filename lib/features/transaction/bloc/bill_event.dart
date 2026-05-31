import 'package:equatable/equatable.dart';

abstract class BillEvent extends Equatable {
  const BillEvent();

  @override
  List<Object> get props => [];
}

class BillFetch extends BillEvent {
  final String studentVa;
  final String studentBank;

  const BillFetch({this.studentVa = '', this.studentBank = 'BCA'});

  @override
  List<Object> get props => [studentVa, studentBank];
}

class BillPay extends BillEvent {
  final int billId;
  final int amount;

  const BillPay({required this.billId, required this.amount});

  @override
  List<Object> get props => [billId, amount];
}

class BillCheckStatus extends BillEvent {
  final String orderId;

  const BillCheckStatus({required this.orderId});

  @override
  List<Object> get props => [orderId];
}
