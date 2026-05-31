import 'package:equatable/equatable.dart';

abstract class ResetPasswordEvent extends Equatable {
  const ResetPasswordEvent();

  @override
  List<Object> get props => [];
}

class ResetPasswordSubmitted extends ResetPasswordEvent {
  final String phone;
  final String otp;
  final String password;
  final String passwordConfirmation;

  const ResetPasswordSubmitted({
    required this.phone,
    required this.otp,
    required this.password,
    required this.passwordConfirmation,
  });

  @override
  List<Object> get props => [phone, otp, password, passwordConfirmation];
}
