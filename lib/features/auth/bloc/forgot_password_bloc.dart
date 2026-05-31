import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import 'forgot_password_event.dart';
import 'forgot_password_state.dart';

class ForgotPasswordBloc
    extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  final ApiClient _apiClient;

  ForgotPasswordBloc({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient(),
        super(ForgotPasswordInitial()) {
    on<ForgotPasswordSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    ForgotPasswordSubmitted event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(ForgotPasswordLoading());
    try {
      await _apiClient.post(
        ApiConfig.forgotPassword,
        body: {'phone': event.phone},
      );
      emit(const ForgotPasswordSuccess(
          message: 'Kode OTP telah dikirim ke WhatsApp Anda'));
    } on ApiException catch (e) {
      emit(ForgotPasswordFailure(error: e.message));
    } catch (_) {
      emit(const ForgotPasswordFailure(
          error: 'Gagal mengirim kode. Periksa koneksi Anda.'));
    }
  }

  @override
  Future<void> close() {
    _apiClient.dispose();
    return super.close();
  }
}
