import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/dashboard_model.dart';
import '../../../core/models/savings_model.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/dashboard_service.dart';
import '../../../core/services/savings_service.dart';
import '../../../core/services/profile_service.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(DashboardInitial()) {
    on<DashboardFetch>(_onFetch);
  }

  Future<void> _onFetch(
    DashboardFetch event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    try {
      final cachedBytes = await ProfileService.getCachedPhotoBytes();

      final dashService = DashboardService();
      final savService = SavingsService();
      final results = await Future.wait([
        dashService.fetch(),
        savService.fetch(),
      ]);
      dashService.dispose();
      savService.dispose();

      final dashData = results[0] as DashboardData?;
      final savData = results[1] as SavingsData?;

      Uint8List? photoBytes = cachedBytes;
      if (photoBytes == null && dashData?.student.photoUrl.isNotEmpty == true) {
        final profileService = ProfileService();
        photoBytes = await profileService.fetchPhotoBytes();
        profileService.dispose();
        if (photoBytes != null) {
          ProfileService.cachePhotoBytes(photoBytes);
        }
      }

      if (photoBytes == null) photoBytes = cachedBytes;

      emit(DashboardLoaded(
        dashboardData: dashData,
        savingsData: savData,
        photoBytes: photoBytes,
      ));
    } on ApiException catch (e) {
      emit(DashboardFailure(error: e.message));
    } catch (_) {
      emit(const DashboardFailure(
          error: 'Terjadi kesalahan. Periksa koneksi Anda.'));
    }
  }
}
