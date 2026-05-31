import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/dashboard_service.dart';
import '../../../core/services/profile_service.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitial()) {
    on<ProfileFetch>(_onFetch);
    on<ProfileUploadPhoto>(_onUploadPhoto);
    on<ProfileDeletePhoto>(_onDeletePhoto);
    on<ProfileUpdateContact>(_onUpdateContact);
  }

  Future<void> _onFetch(
    ProfileFetch event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final cachedBytes = await ProfileService.getCachedPhotoBytes();

      final dashService = DashboardService();
      final data = await dashService.fetch();
      dashService.dispose();

      Uint8List? photoBytes = cachedBytes;
      if (photoBytes == null && data?.student.photoUrl.isNotEmpty == true) {
        final profileService = ProfileService();
        photoBytes = await profileService.fetchPhotoBytes();
        profileService.dispose();
        if (photoBytes != null) {
          ProfileService.cachePhotoBytes(photoBytes);
        }
      }

      emit(ProfileLoaded(
        dashboardData: data,
        photoBytes: photoBytes ?? cachedBytes,
      ));
    } on ApiException catch (e) {
      emit(ProfileFailure(error: e.message));
    } catch (_) {
      emit(const ProfileFailure(
          error: 'Terjadi kesalahan. Periksa koneksi Anda.'));
    }
  }

  Future<void> _onUploadPhoto(
    ProfileUploadPhoto event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfilePhotoUploading(previewBytes: Uint8List.fromList(event.bytes)));
    ProfileService.cachePhotoBytes(Uint8List.fromList(event.bytes));

    final service = ProfileService();
    final photoUrl = await service.uploadPhoto(
      bytes: event.bytes,
      fileName: event.fileName,
    );
    service.dispose();

    if (photoUrl != null) {
      emit(const ProfilePhotoSuccess(message: 'Photo berhasil diperbarui'));
      add(ProfileFetch());
    } else {
      emit(const ProfileFailure(error: 'Gagal mengupload photo'));
    }
  }

  Future<void> _onDeletePhoto(
    ProfileDeletePhoto event,
    Emitter<ProfileState> emit,
  ) async {
    final service = ProfileService();
    final success = await service.deletePhoto();
    service.dispose();

    if (success) {
      ProfileService.clearCachedPhoto();
      emit(const ProfilePhotoSuccess(message: 'Photo berhasil dihapus'));
      add(ProfileFetch());
    } else {
      emit(const ProfileFailure(error: 'Gagal menghapus photo'));
    }
  }

  Future<void> _onUpdateContact(
    ProfileUpdateContact event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      final state = this.state;
      String fatherPhone = event.fatherPhone ?? '';
      String motherPhone = event.motherPhone ?? '';
      String address = event.address ?? '';

      if (state is ProfileLoaded && state.dashboardData != null) {
        final student = state.dashboardData!.student;
        fatherPhone = event.fatherPhone ?? student.fatherName;
        motherPhone = event.motherPhone ?? student.motherName;
        address = event.address ?? student.address;
      }

      final service = ProfileService();
      final success = await service.updateContact(
        fatherPhone: fatherPhone,
        motherPhone: motherPhone,
        address: address,
      );
      service.dispose();

      if (success) {
        add(ProfileFetch());
      } else {
        emit(const ProfileFailure(error: 'Gagal memperbarui data'));
      }
    } on ApiException catch (e) {
      emit(ProfileFailure(error: e.message));
    } catch (_) {
      emit(const ProfileFailure(error: 'Gagal memperbarui data'));
    }
  }
}
