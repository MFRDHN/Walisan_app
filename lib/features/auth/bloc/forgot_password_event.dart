import 'package:equatable/equatable.dart';

abstract class ForgotPasswordEvent extends Equatable {
  const ForgotPasswordEvent();

  @override
  List<Object> get props => [];
}

class ForgotPasswordSubmitted extends ForgotPasswordEvent {
  final String phone;

  const ForgotPasswordSubmitted({required this.phone});

  @override
  List<Object> get props => [phone];
}
