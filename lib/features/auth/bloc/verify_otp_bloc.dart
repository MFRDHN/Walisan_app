import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import '../../../core/models/login_response_model.dart';
import 'verify_otp_event.dart';
import 'verify_otp_state.dart';

class VerifyOtpBloc extends Bloc<VerifyOtpEvent, VerifyOtpState> {
  final ApiClient _apiClient;

  VerifyOtpBloc({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient(),
        super(VerifyOtpInitial()) {
    on<VerifyOtpSubmitted>(_onVerifyOtpSubmitted);
    on<ResendOtpRequested>(_onResendOtpRequested);
  }

  Future<void> _onVerifyOtpSubmitted(
    VerifyOtpSubmitted event,
    Emitter<VerifyOtpState> emit,
  ) async {
    emit(VerifyOtpLoading());
    try {
      final response = await _apiClient.post(
        ApiConfig.verifyOtp,
        body: {
          'user_id': event.userId.toString(),
          'otp_code': event.otpCode,
        },
      );

      final loginResponse = LoginResponseModel.fromJson(response);
      emit(VerifyOtpSuccess(loginResponse: loginResponse));
    } on ApiException catch (e) {
      emit(VerifyOtpFailure(error: e.message));
    } catch (e) {
      emit(VerifyOtpFailure(error: e.toString()));
    }
  }

  Future<void> _onResendOtpRequested(
    ResendOtpRequested event,
    Emitter<VerifyOtpState> emit,
  ) async {
    emit(VerifyOtpLoading());
    try {
      final response = await _apiClient.post(
        ApiConfig.resendOtp,
        body: {
          'user_id': event.userId.toString(),
        },
      );

      final message = response['message'] as String? ?? 'Kode OTP telah dikirim ulang';
      emit(ResendOtpSuccess(message: message));
    } on ApiException catch (e) {
      emit(VerifyOtpFailure(error: e.message));
    } catch (e) {
      emit(VerifyOtpFailure(error: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _apiClient.dispose();
    return super.close();
  }
}
