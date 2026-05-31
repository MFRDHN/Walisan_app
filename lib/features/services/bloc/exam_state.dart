import 'package:equatable/equatable.dart';

abstract class ExamState extends Equatable {
  const ExamState();

  @override
  List<Object?> get props => [];
}

class ExamInitial extends ExamState {}

class ExamLoading extends ExamState {}

class ExamLoaded extends ExamState {
  final List<dynamic> exams;
  final String? token;

  const ExamLoaded({required this.exams, this.token});

  @override
  List<Object?> get props => [exams, token];
}

class ExamFailure extends ExamState {
  final String error;

  const ExamFailure({required this.error});

  @override
  List<Object> get props => [error];
}
