import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import 'exam_event.dart';
import 'exam_state.dart';

class ExamBloc extends Bloc<ExamEvent, ExamState> {
  final ApiClient _apiClient;

  ExamBloc({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient(),
        super(ExamInitial()) {
    on<ExamFetch>(_onFetch);
  }

  Future<void> _onFetch(
    ExamFetch event,
    Emitter<ExamState> emit,
  ) async {
    emit(ExamLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        emit(const ExamFailure(
            error: 'Token tidak ditemukan. Silakan login ulang.'));
        return;
      }

      final response = await _apiClient.get(
        ApiConfig.exams,
        token: token,
      );

      final list = response['data'] as List<dynamic>? ?? [];
      emit(ExamLoaded(exams: list, token: token));
    } on ApiException catch (e) {
      emit(ExamFailure(error: e.message));
    } catch (_) {
      emit(const ExamFailure(
          error: 'Gagal memuat ujian. Periksa koneksi Anda.'));
    }
  }

  @override
  Future<void> close() {
    _apiClient.dispose();
    return super.close();
  }
}
