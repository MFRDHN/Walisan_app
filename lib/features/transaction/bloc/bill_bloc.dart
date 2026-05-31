import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import 'bill_event.dart';
import 'bill_state.dart';

class BillBloc extends Bloc<BillEvent, BillState> {
  final ApiClient _apiClient;

  BillBloc({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient(),
        super(BillInitial()) {
    on<BillFetch>(_onFetch);
    on<BillPay>(_onPay);
    on<BillCheckStatus>(_onCheckStatus);
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _onFetch(
    BillFetch event,
    Emitter<BillState> emit,
  ) async {
    emit(BillLoading());
    try {
      final token = await _getToken();
      if (token == null) {
        emit(const BillFailure(
            error: 'Token tidak ditemukan. Silakan login ulang.'));
        return;
      }

      final response = await _apiClient.get(
        ApiConfig.bills,
        token: token,
      );

      final list = response['data'] as List<dynamic>? ?? [];
      final studentName = response['student_name'] as String? ??
          (list.isNotEmpty ? list.first['title'] as String? ?? '' : '');

      emit(BillLoaded(
        bills: list,
        studentName: studentName,
        studentVa: event.studentVa,
        studentBank: event.studentBank,
      ));
    } on ApiException catch (e) {
      emit(BillFailure(error: e.message));
    } catch (_) {
      emit(const BillFailure(
          error: 'Gagal memuat tagihan. Periksa koneksi Anda.'));
    }
  }

  Future<void> _onPay(
    BillPay event,
    Emitter<BillState> emit,
  ) async {
    emit(BillPayLoading(billId: event.billId));
    try {
      final token = await _getToken();
      if (token == null) {
        emit(const BillFailure(
            error: 'Token tidak ditemukan. Silakan login ulang.'));
        return;
      }

      final response = await _apiClient.post(
        ApiConfig.billsPay,
        token: token,
        body: {
          'bill_id': event.billId,
          'amount': event.amount,
        },
      );

      if (response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>?;
        final redirectUrl = data?['redirect_url'] as String?;
        final orderId = data?['order_id'] as String? ?? '';

        if (redirectUrl != null && redirectUrl.isNotEmpty) {
          emit(BillPayReady(redirectUrl: redirectUrl, orderId: orderId));
        } else {
          emit(const BillFailure(error: 'URL pembayaran tidak tersedia.'));
        }
      } else {
        emit(BillFailure(
            error: response['message'] as String? ?? 'Pembayaran gagal.'));
      }
    } on ApiException catch (e) {
      emit(BillFailure(error: e.message));
    } catch (_) {
      emit(const BillFailure(error: 'Gagal terhubung ke server.'));
    }
  }

  Future<void> _onCheckStatus(
    BillCheckStatus event,
    Emitter<BillState> emit,
  ) async {
    try {
      final token = await _getToken();
      if (token == null) return;

      await _apiClient.post(
        ApiConfig.billsCheckStatus,
        token: token,
        body: {'order_id': event.orderId},
      );
    } catch (_) {}
  }

  @override
  Future<void> close() {
    _apiClient.dispose();
    return super.close();
  }
}
