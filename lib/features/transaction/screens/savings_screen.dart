import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/models/savings_model.dart';
import '../bloc/savings_bloc.dart';
import '../bloc/savings_event.dart';
import '../bloc/savings_state.dart';
import 'topup_saldo_page.dart';

class SavingsScreen extends StatelessWidget {
  const SavingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SavingsBloc()..add(SavingsFetch()),
      child: const _SavingsView(),
    );
  }
}

class _SavingsView extends StatefulWidget {
  const _SavingsView();

  @override
  State<_SavingsView> createState() => _SavingsViewState();
}

class _SavingsViewState extends State<_SavingsView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  static const Color hijauUtama = Color(0xFF0EB89A);
  static const Color hijauTua = Color(0xFF0A9688);

  final List<String> _monthNames = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  final formatRupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SavingsBloc, SavingsState>(
      listener: (context, state) {
        if (state is SavingsFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        final data = state is SavingsLoaded ? state.data : null;
        final history = state is SavingsLoaded ? state.history : <SavingsTransaction>[];
        final monthlyIncome = state is SavingsLoaded ? state.monthlyIncome : 0;
        final monthlyExpense = state is SavingsLoaded ? state.monthlyExpense : 0;
        final isLoading = state is SavingsLoading;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.black87, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            centerTitle: false,
            title: const Text('Tabungan',
                style: TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
          ),
          body: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: hijauUtama))
              : RefreshIndicator(
                  onRefresh: () async {
                    context.read<SavingsBloc>().add(SavingsFetch());
                  },
                  color: hijauUtama,
                  backgroundColor: Colors.white,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildKartuSaldo(
                                  data, monthlyIncome, monthlyExpense),
                              const SizedBox(height: 24),
                              _buildHeaderRiwayat(),
                              const SizedBox(height: 10),
                              _buildDaftarTransaksi(history),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildKartuSaldo(
      SavingsData? data, int monthlyIncome, int monthlyExpense) {
    final balance = data?.balance ?? 0;
    final name = data?.studentName ?? 'Santri';
    final limit = data?.dailyLimit ?? 0;
    final pocket = data?.pocketMoney ?? 0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [hijauUtama, hijauTua],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: hijauUtama.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.account_balance_wallet_rounded,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Saldo Tabungan -',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500)),
                    Text(name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(formatRupiah.format(balance),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5)),
            const SizedBox(height: 4),
            Text(
                'Limit Jajan : ${formatRupiah.format(limit)}  |  Uang Jajan: ${formatRupiah.format(pocket)}',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.7), fontSize: 11)),
            const SizedBox(height: 10),
            Text('Rekap Bulan ${_monthNames[DateTime.now().month - 1]}',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.65),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: _buildStatBox(
                    icon: Icons.arrow_downward_rounded,
                    label: 'Pemasukan',
                    nilai: formatRupiah.format(monthlyIncome),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildStatBox(
                    icon: Icons.arrow_upward_rounded,
                    label: 'Pengeluaran',
                    nilai: formatRupiah.format(monthlyExpense),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildCardButton(
                    icon: Icons.add_rounded,
                    label: 'Top Up Saldo',
                    onTap: () => _showTopUpDialog(
                        context,
                        data?.balance ?? 0,
                        data?.studentName ?? 'Santri'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildCardButton(
                    icon: Icons.tune_rounded,
                    label: 'Update Limit Jajan',
                    onTap: () => _showLimitDialog(context, data),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox({
    required IconData icon,
    required String label,
    required String nilai,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.75), fontSize: 10.5)),
              Text(nilai,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        splashColor: Colors.white24,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border:
                Border.all(color: Colors.white.withOpacity(0.5), width: 1.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 5),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRiwayat() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Riwayat Transaksi',
            style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w700)),
        TextButton(
          onPressed: () {},
          child: const Text('Lihat Semua',
              style: TextStyle(
                  color: hijauUtama,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildDaftarTransaksi(List<SavingsTransaction> history) {
    if (history.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Icon(Icons.receipt_long_outlined,
                color: Colors.black.withOpacity(0.15), size: 40),
            const SizedBox(height: 8),
            Text('Belum ada transaksi',
                style: TextStyle(
                    color: Colors.black.withOpacity(0.35), fontSize: 13)),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: history.length,
      separatorBuilder: (_, __) => const Divider(
        color: Color(0xFFF0F0F0),
        height: 1,
      ),
      itemBuilder: (context, index) {
        return _buildItemTransaksi(history[index]);
      },
    );
  }

  Widget _buildItemTransaksi(SavingsTransaction trx) {
    final tanggalFmt = trx.date.length >= 10
        ? trx.date.substring(0, 10).split('-').reversed.join('-')
        : trx.date;
    final bool isDebit = trx.isDebit;
    final Color warnaJumlah =
        isDebit ? const Color(0xFFE53935) : hijauUtama;
    final String prefixJumlah = isDebit ? '-' : '+';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: warnaJumlah.withOpacity(0.4),
                width: 1.5,
              ),
            ),
            child: Icon(
              isDebit
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              color: warnaJumlah,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trx.description,
                    style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 3),
                Text(tanggalFmt,
                    style: TextStyle(
                        color: Colors.black.withOpacity(0.4),
                        fontSize: 11.5)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$prefixJumlah${formatRupiah.format(trx.amount)}',
                  style: TextStyle(
                      color: warnaJumlah,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 3),
              Text('Saldo ${formatRupiah.format(trx.balanceAfter)}',
                  style: TextStyle(
                      color: Colors.black.withOpacity(0.38), fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showTopUpDialog(
      BuildContext context, int balance, String studentName) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TopUpSaldoPage(
          currentBalance: balance,
          studentName: studentName,
        ),
      ),
    );
    if (result == true && context.mounted) {
      context.read<SavingsBloc>().add(SavingsFetch());
    }
  }

  void _showLimitDialog(BuildContext context, SavingsData? data) {
    final controller = TextEditingController(
      text: data?.dailyLimit.toString() ?? '',
    );
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Update Limit Jajan',
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(
                  'Limit saat ini: ${formatRupiah.format(data?.dailyLimit ?? 0)} / hari',
                  style:
                      const TextStyle(color: Colors.black45, fontSize: 13)),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Masukkan limit baru',
                  hintStyle: const TextStyle(color: Colors.black38),
                  prefixText: 'Rp ',
                  prefixStyle: const TextStyle(
                      color: Colors.black87, fontWeight: FontWeight.w600),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          final value = int.tryParse(
                              controller.text.replaceAll('.', ''));
                          if (value == null || value <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Masukkan nominal valid'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          setSheetState(() => isLoading = true);
                          if (!ctx.mounted) return;
                          context
                              .read<SavingsBloc>()
                              .add(SavingsUpdateLimit(dailyLimit: value));
                          Navigator.pop(ctx);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hijauUtama,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text('Simpan Limit',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
