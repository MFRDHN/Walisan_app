import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import 'change_password_event.dart';
import 'change_password_state.dart';

class ChangePasswordBloc
    extends Bloc<ChangePasswordEvent, ChangePasswordState> {
  final ApiClient _apiClient;

  ChangePasswordBloc({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient(),
        super(ChangePasswordInitial()) {
    on<ChangePasswordSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    ChangePasswordSubmitted event,
    Emitter<ChangePasswordState> emit,
  ) async {
    emit(ChangePasswordLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        emit(const ChangePasswordFailure(
            error: 'Token tidak ditemukan. Silakan login ulang.'));
        return;
      }

      await _apiClient.post(
        ApiConfig.changePassword,
        token: token,
        body: {
          'current_password': event.currentPassword,
          'new_password': event.newPassword,
          'new_password_confirmation': event.confirmPassword,
        },
      );
      emit(ChangePasswordSuccess());
    } on ApiException catch (e) {
      emit(ChangePasswordFailure(error: e.message));
    } catch (_) {
      emit(const ChangePasswordFailure(
          error: 'Terjadi kesalahan. Periksa koneksi Anda.'));
    }
  }

  @override
  Future<void> close() {
    _apiClient.dispose();
    return super.close();
  }
}
