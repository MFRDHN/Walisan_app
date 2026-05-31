import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import 'history_event.dart';
import 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final ApiClient _apiClient;

  HistoryBloc({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient(),
        super(HistoryInitial()) {
    on<HistoryFetch>(_onFetch);
  }

  Future<void> _onFetch(
    HistoryFetch event,
    Emitter<HistoryState> emit,
  ) async {
    emit(HistoryLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        emit(const HistoryFailure(
            error: 'Token tidak ditemukan. Silakan login ulang.'));
        return;
      }

      final response = await _apiClient.get(
        ApiConfig.payments,
        token: token,
      );

      final list = response['data'] as List<dynamic>? ?? [];
      int totalAmount = 0;
      for (final item in list) {
        if (item is Map<String, dynamic>) {
          final status = item['status'] as String? ?? '';
          if (status == 'success') {
            totalAmount += (item['amount'] as int? ?? 0);
          }
        }
      }

      emit(HistoryLoaded(payments: list, totalAmount: totalAmount));
    } on ApiException catch (e) {
      emit(HistoryFailure(error: e.message));
    } catch (_) {
      emit(const HistoryFailure(
          error: 'Gagal memuat riwayat. Periksa koneksi Anda.'));
    }
  }

  @override
  Future<void> close() {
    _apiClient.dispose();
    return super.close();
  }
}
