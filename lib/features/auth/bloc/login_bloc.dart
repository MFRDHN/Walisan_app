import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import '../../../core/models/login_response_model.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final ApiClient _apiClient;

  LoginBloc({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient(),
        super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    final username = event.username.trim();
    final password = event.password;

    final usernameError =
        username.isEmpty ? 'Username tidak boleh kosong' : null;
    final passwordError =
        password.isEmpty ? 'Kata sandi tidak boleh kosong' : null;

    if (usernameError != null || passwordError != null) {
      emit(LoginFormInvalid(
        usernameError: usernameError,
        passwordError: passwordError,
      ));
      return;
    }

    emit(LoginLoading());
    try {
      final response = await _apiClient.post(
        ApiConfig.login,
        body: {
          'identifier': username,
          'password': password,
        },
      );

      final loginResponse = LoginResponseModel.fromJson(response);
      emit(LoginSuccess(loginResponse: loginResponse));
    } on ApiException catch (e) {
      emit(LoginFailure(error: e.message));
    } catch (e) {
      emit(LoginFailure(error: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _apiClient.dispose();
    return super.close();
  }
}
