import 'package:equatable/equatable.dart';
import '../../../core/models/login_response_model.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object> get props => [];
}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final LoginResponseModel loginResponse;

  const LoginSuccess({required this.loginResponse});

  @override
  List<Object> get props => [loginResponse];
}

class LoginFailure extends LoginState {
  final String error;

  const LoginFailure({required this.error});

  @override
  List<Object> get props => [error];
}

class LoginFormInvalid extends LoginState {
  final String? usernameError;
  final String? passwordError;

  const LoginFormInvalid({this.usernameError, this.passwordError});

  @override
  List<Object> get props => [usernameError ?? '', passwordError ?? ''];
}
