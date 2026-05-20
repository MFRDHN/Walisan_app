import 'package:equatable/equatable.dart';

abstract class VerifyOtpEvent extends Equatable {
  const VerifyOtpEvent();

  @override
  List<Object> get props => [];
}

class VerifyOtpSubmitted extends VerifyOtpEvent {
  final int userId;
  final String otpCode;

  const VerifyOtpSubmitted({
    required this.userId,
    required this.otpCode,
  });

  @override
  List<Object> get props => [userId, otpCode];
}

class ResendOtpRequested extends VerifyOtpEvent {
  final int userId;

  const ResendOtpRequested({required this.userId});

  @override
  List<Object> get props => [userId];
}
