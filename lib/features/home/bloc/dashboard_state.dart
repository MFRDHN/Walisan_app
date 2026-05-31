import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import '../../../core/models/dashboard_model.dart';
import '../../../core/models/savings_model.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final DashboardData? dashboardData;
  final SavingsData? savingsData;
  final Uint8List? photoBytes;

  const DashboardLoaded({
    this.dashboardData,
    this.savingsData,
    this.photoBytes,
  });

  @override
  List<Object?> get props => [dashboardData, savingsData, photoBytes];
}

class DashboardFailure extends DashboardState {
  final String error;

  const DashboardFailure({required this.error});

  @override
  List<Object> get props => [error];
}
