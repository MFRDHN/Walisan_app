import 'package:equatable/equatable.dart';
import '../../../core/models/register_response_model.dart';

abstract class RegisterState extends Equatable {
  const RegisterState();

  @override
  List<Object> get props => [];
}

class RegisterInitial extends RegisterState {}

class RegisterLoading extends RegisterState {}

class RegisterSuccess extends RegisterState {
  final RegisterResponseModel registerResponse;

  const RegisterSuccess({required this.registerResponse});

  @override
  List<Object> get props => [registerResponse];
}

class RegisterFailure extends RegisterState {
  final String error;

  const RegisterFailure({required this.error});

  @override
  List<Object> get props => [error];
}
