import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class ProfileFetch extends ProfileEvent {}

class ProfileUploadPhoto extends ProfileEvent {
  final List<int> bytes;
  final String fileName;

  const ProfileUploadPhoto({required this.bytes, required this.fileName});

  @override
  List<Object> get props => [bytes, fileName];
}

class ProfileDeletePhoto extends ProfileEvent {}

class ProfileUpdateContact extends ProfileEvent {
  final String? fatherPhone;
  final String? motherPhone;
  final String? address;

  const ProfileUpdateContact({
    this.fatherPhone,
    this.motherPhone,
    this.address,
  });

  @override
  List<Object> get props => [fatherPhone ?? '', motherPhone ?? '', address ?? ''];
}
