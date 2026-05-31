import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/services/savings_service.dart';
import 'pembayaran_topup_page.dart';

class TopUpSaldoPage extends StatefulWidget {
  final int currentBalance;

  const TopUpSaldoPage({super.key, required this.currentBalance});

  @override
  State<TopUpSaldoPage> createState() => _TopUpSaldoPageState();
}

class _TopUpSaldoPageState extends State<TopUpSaldoPage> {
  static const Color hijauUtama = Color(0xFF0EB89A);

  final _service = SavingsService();
  bool _isLoading = false;

  final formatRupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  int? selectedNominal;
  String? selectedMetode;

  final List<int> nominalList = [50000, 100000, 150000, 200000];

  final List<Map<String, dynamic>> metodeList = [
    {
      'id': 'virtual_account',
      'label': 'Virtual Account',
      'sublabel': 'BCA, BNI, BRI, Permata, Mandiri',
      'icon': Icons.account_balance_outlined,
      'isQris': false,
    },
    {
      'id': 'ewallet',
      'label': 'E-Wallet',
      'sublabel': 'GoPay, ShopeePay',
      'icon': Icons.account_balance_wallet_outlined,
      'isQris': false,
    },
    {
      'id': 'mitra',
      'label': 'Mitra / Agen',
      'sublabel': 'Indomaret, Alfamart',
      'icon': Icons.store_outlined,
      'isQris': false,
    },
    {
      'id': 'kartu_debit',
      'label': 'Kartu Debit / Kredit',
      'sublabel': 'Visa, Mastercard, JCB',
      'icon': Icons.credit_card_outlined,
      'isQris': false,
    },
    {
      'id': 'qris',
      'label': 'QRIS',
      'sublabel': 'Semua bank & e-wallet',
      'icon': null,
      'isQris': true,
    },
  ];

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  bool get _canProceed => selectedNominal != null && selectedMetode != null;

  Future<void> _lanjutkan() async {
    if (!_canProceed || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      final result = await _service.topUp(
        amount: selectedNominal!,
        paymentMethod: selectedMetode,
      );

      if (!mounted) return;

      if (result != null) {
        final kembali = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => PembayaranTopUpPage(
              snapData: result,
              nominal: selectedNominal!,
              metode: selectedMetode!,
              metodeLabel: metodeList
                  .firstWhere((m) => m['id'] == selectedMetode)['label']
                  as String,
              currentBalance: widget.currentBalance,
            ),
          ),
        );

        if (kembali == true && mounted) {
          Navigator.pop(context, true);
        }
      } else {
        _showError('Gagal membuat token pembayaran. Coba lagi.');
      }
    } catch (e) {
      _showError('Tidak dapat terhubung ke server.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        title: const Text(
          'Top Up Saldo',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Saldo saat ini',
                          style: TextStyle(
                              color: Colors.black54,
                              fontSize: 13,
                              fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatRupiah.format(widget.currentBalance),
                          style: const TextStyle(
                            color: hijauUtama,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Jumlah Top Up',
                          style: TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                              fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 12),
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 3.2,
                          children: nominalList.map((nominal) {
                            final isSelected = selectedNominal == nominal;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => selectedNominal = nominal),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? hijauUtama.withValues(alpha: 0.08)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected
                                        ? hijauUtama
                                        : const Color(0xFFDDDDDD),
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  formatRupiah.format(nominal),
                                  style: TextStyle(
                                    color: isSelected
                                        ? hijauUtama
                                        : Colors.black54,
                                    fontSize: 13,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  const Text(
                    'Metode Pembayaran',
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border:
                          Border.all(color: const Color(0xFFEEEEEE), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: List.generate(metodeList.length, (index) {
                        final metode = metodeList[index];
                        final isLast = index == metodeList.length - 1;
                        final isQris = metode['isQris'] as bool;
                        final isSelected = selectedMetode == metode['id'];

                        return Column(
                          children: [
                            InkWell(
                              onTap: () =>
                                  setState(() => selectedMetode = metode['id']),
                              borderRadius: BorderRadius.vertical(
                                top: index == 0
                                    ? const Radius.circular(14)
                                    : Radius.zero,
                                bottom: isLast
                                    ? const Radius.circular(14)
                                    : Radius.zero,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 12),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        color: isQris
                                            ? Colors.white
                                            : hijauUtama.withValues(alpha: 0.10),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                        border: isQris
                                            ? Border.all(
                                                color: const Color(0xFFDDDDDD))
                                            : null,
                                      ),
                                      child: isQris
                                          ? Center(
                                              child: Text(
                                                'QR',
                                                style: TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w800,
                                                  letterSpacing: -0.5,
                                                ),
                                              ),
                                            )
                                          : Icon(
                                              metode['icon'] as IconData,
                                              color: hijauUtama,
                                              size: 20,
                                            ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            metode['label'] as String,
                                            style: const TextStyle(
                                              color: Colors.black87,
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            metode['sublabel'] as String,
                                            style: const TextStyle(
                                              color: Colors.black45,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected
                                              ? hijauUtama
                                              : const Color(0xFFCCCCCC),
                                          width: 1.5,
                                        ),
                                        color: isSelected
                                            ? hijauUtama
                                            : Colors.white,
                                      ),
                                      child: isSelected
                                          ? const Icon(Icons.check,
                                              color: Colors.white, size: 13)
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (!isLast)
                              const Divider(
                                height: 1,
                                color: Color(0xFFF2F2F2),
                                indent: 14,
                                endIndent: 14,
                              ),
                          ],
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _canProceed && !_isLoading ? _lanjutkan : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: hijauUtama,
                  disabledBackgroundColor: hijauUtama.withValues(alpha: 0.4),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'Lanjutkan Pembayaran',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}
