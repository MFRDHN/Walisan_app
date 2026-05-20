import 'package:equatable/equatable.dart';

abstract class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object> get props => [];
}

class RegisterSubmitted extends RegisterEvent {
  final String studentName;
  final String nis;
  final String phone;
  final String password;
  final String passwordConfirmation;

  const RegisterSubmitted({
    required this.studentName,
    required this.nis,
    required this.phone,
    required this.password,
    required this.passwordConfirmation,
  });

  @override
  List<Object> get props =>
      [studentName, nis, phone, password, passwordConfirmation];
}
