import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import 'reset_password_event.dart';
import 'reset_password_state.dart';

class ResetPasswordBloc
    extends Bloc<ResetPasswordEvent, ResetPasswordState> {
  final ApiClient _apiClient;

  ResetPasswordBloc({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient(),
        super(ResetPasswordInitial()) {
    on<ResetPasswordSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    ResetPasswordSubmitted event,
    Emitter<ResetPasswordState> emit,
  ) async {
    emit(ResetPasswordLoading());
    try {
      await _apiClient.post(
        ApiConfig.resetPassword,
        body: {
          'phone': event.phone,
          'otp': event.otp,
          'password': event.password,
          'password_confirmation': event.passwordConfirmation,
        },
      );
      emit(ResetPasswordSuccess());
    } on ApiException catch (e) {
      emit(ResetPasswordFailure(error: e.message));
    } catch (_) {
      emit(const ResetPasswordFailure(
          error: 'Gagal mereset password. Periksa koneksi Anda.'));
    }
  }

  @override
  Future<void> close() {
    _apiClient.dispose();
    return super.close();
  }
}
