import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import '../../../core/models/dashboard_model.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final DashboardData? dashboardData;
  final Uint8List? photoBytes;

  const ProfileLoaded({this.dashboardData, this.photoBytes});

  @override
  List<Object?> get props => [dashboardData, photoBytes];
}

class ProfilePhotoUploading extends ProfileState {
  final Uint8List? previewBytes;

  const ProfilePhotoUploading({this.previewBytes});

  @override
  List<Object?> get props => [previewBytes];
}

class ProfilePhotoSuccess extends ProfileState {
  final String message;

  const ProfilePhotoSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class ProfileFailure extends ProfileState {
  final String error;

  const ProfileFailure({required this.error});

  @override
  List<Object> get props => [error];
}
