import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import '../../../core/models/register_response_model.dart';
import 'register_event.dart';
import 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final ApiClient _apiClient;

  RegisterBloc({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient(),
        super(RegisterInitial()) {
    on<RegisterSubmitted>(_onRegisterSubmitted);
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    emit(RegisterLoading());
    try {
      final response = await _apiClient.post(
        ApiConfig.register,
        body: {
          'student_name': event.studentName,
          'nis': event.nis,
          'phone': event.phone,
          'password': event.password,
          'password_confirmation': event.passwordConfirmation,
        },
      );

      final registerResponse = RegisterResponseModel.fromJson(response);
      emit(RegisterSuccess(registerResponse: registerResponse));
    } on ApiException catch (e) {
      emit(RegisterFailure(error: e.message));
    } catch (e) {
      emit(RegisterFailure(error: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _apiClient.dispose();
    return super.close();
  }
}
