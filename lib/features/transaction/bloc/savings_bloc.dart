import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/savings_model.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/savings_service.dart';
import 'savings_event.dart';
import 'savings_state.dart';

class SavingsBloc extends Bloc<SavingsEvent, SavingsState> {
  final SavingsService _service;

  SavingsBloc({SavingsService? service})
      : _service = service ?? SavingsService(),
        super(SavingsInitial()) {
    on<SavingsFetch>(_onFetch);
    on<SavingsUpdateLimit>(_onUpdateLimit);
    on<SavingsTopUp>(_onTopUp);
  }

  Future<void> _onFetch(
    SavingsFetch event,
    Emitter<SavingsState> emit,
  ) async {
    emit(SavingsLoading());
    try {
      final data = await _service.fetch();
      List<SavingsTransaction> history = data?.history ?? [];
      if (history.isEmpty) {
        history = await _service.fetchHistory();
      }

      final now = DateTime.now();
      int income = 0;
      int expense = 0;
      for (final trx in history) {
        final date = _parseDate(trx.date);
        if (date != null && date.month == now.month && date.year == now.year) {
          if (trx.isDebit) {
            expense += trx.amount;
          } else {
            income += trx.amount;
          }
        }
      }

      emit(SavingsLoaded(
        data: data,
        history: history,
        monthlyIncome: income,
        monthlyExpense: expense,
      ));
    } on ApiException catch (e) {
      emit(SavingsFailure(error: e.message));
    } catch (_) {
      emit(const SavingsFailure(
          error: 'Terjadi kesalahan. Periksa koneksi Anda.'));
    }
  }

  Future<void> _onUpdateLimit(
    SavingsUpdateLimit event,
    Emitter<SavingsState> emit,
  ) async {
    emit(SavingsLimitUpdating());
    try {
      await _service.updateLimit(event.dailyLimit);
      add(SavingsFetch());
    } on ApiException catch (e) {
      emit(SavingsFailure(error: e.message));
    } catch (_) {
      emit(const SavingsFailure(
          error: 'Gagal update limit. Coba lagi.'));
    }
  }

  Future<void> _onTopUp(
    SavingsTopUp event,
    Emitter<SavingsState> emit,
  ) async {
    try {
      await _service.topUp(
        amount: event.amount,
        paymentMethod: event.paymentMethod,
      );
    } catch (_) {}
  }

  DateTime? _parseDate(String dateStr) {
    DateTime? date = DateTime.tryParse(dateStr);
    if (date != null) return date;
    try {
      final parts = dateStr.split(' ');
      if (parts.isNotEmpty) {
        date = DateTime.tryParse(parts[0]);
        if (date != null) return date;
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<void> close() {
    _service.dispose();
    return super.close();
  }
}
