import 'package:equatable/equatable.dart';
import '../../../core/models/login_response_model.dart';

abstract class VerifyOtpState extends Equatable {
  const VerifyOtpState();

  @override
  List<Object> get props => [];
}

class VerifyOtpInitial extends VerifyOtpState {}

class VerifyOtpLoading extends VerifyOtpState {}

class VerifyOtpSuccess extends VerifyOtpState {
  final LoginResponseModel loginResponse;

  const VerifyOtpSuccess({required this.loginResponse});

  @override
  List<Object> get props => [loginResponse];
}

class VerifyOtpFailure extends VerifyOtpState {
  final String error;

  const VerifyOtpFailure({required this.error});

  @override
  List<Object> get props => [error];
}

class ResendOtpSuccess extends VerifyOtpState {
  final String message;

  const ResendOtpSuccess({required this.message});

  @override
  List<Object> get props => [message];
}
