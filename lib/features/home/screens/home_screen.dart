import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:intl/intl.dart';
import '../../../core/models/dashboard_model.dart';
import '../../../core/models/savings_model.dart';
import '../../../core/services/logout_service.dart';
import '../../../shared/widgets/exit_confirmation_dialog.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';

class HomeScreen extends StatelessWidget {
  final String? loginData;

  const HomeScreen({super.key, this.loginData});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DashboardBloc()..add(DashboardFetch()),
      child: _HomeView(loginData: loginData),
    );
  }
}

class _HomeView extends StatelessWidget {
  final String? loginData;

  const _HomeView({this.loginData});

  Map<String, dynamic>? get _loginStudent {
    if (loginData == null) return null;
    try {
      final data = jsonDecode(loginData!);
      return data['student'] as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }

  static const _gradient = LinearGradient(
    colors: [Color(0xFF067A88), Color(0xFF0EA473)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static final _formatRupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DashboardBloc, DashboardState>(
      listener: (context, state) {
        if (state is DashboardFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        final dashData = state is DashboardLoaded ? state.dashboardData : null;
        final savData = state is DashboardLoaded ? state.savingsData : null;
        final photoBytes = state is DashboardLoaded ? state.photoBytes : null;

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: SafeArea(
            child: state is DashboardLoading && dashData == null
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF0EA473)))
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            _buildHeader(context),
                            Positioned(
                              top: 163,
                              left: 0,
                              right: 0,
                              child: _buildProfileCard(
                                  dashData, photoBytes, _loginStudent),
                            ),
                            Opacity(
                              opacity: 0,
                              child: Column(
                                children: [
                                  const SizedBox(height: 157 + 6),
                                  _buildProfileCard(
                                      dashData, photoBytes, _loginStudent),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const _SectionTitle(),
                        const SizedBox(height: 16),
                        _buildServiceGrid(dashData, context),
                        const SizedBox(height: 16),
                        _buildAnnouncement(),
                        const SizedBox(height: 16),
                        _buildBottomInfo(dashData, savData),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }

  String _studentName(DashboardData? dashData) {
    if (dashData != null) return dashData.student.name;
    final student = _loginStudent;
    return (student?['name'] as String?) ?? '-';
  }

  String _studentClass(DashboardData? dashData) {
    if (dashData != null) return dashData.student.studentClass;
    final student = _loginStudent;
    return (student?['class'] as String?) ?? '-';
  }

  String _studentRoom(DashboardData? dashData) {
    if (dashData != null) return dashData.student.room;
    final student = _loginStudent;
    return (student?['room'] as String?) ?? '-';
  }

  String _barcodeId(DashboardData? dashData) {
    if (dashData != null) return dashData.student.barcodeId;
    final student = _loginStudent;
    return (student?['barcode_id'] as String?) ?? '-';
  }

  String _nis(DashboardData? dashData) {
    if (dashData != null) return dashData.student.nis;
    final student = _loginStudent;
    return (student?['nis'] as String?) ?? '-';
  }

  String _academicYear(DashboardData? dashData) {
    if (dashData != null) {
      return dashData.student.enrollmentYear.replaceAll('-', '/');
    }
    final student = _loginStudent;
    final year = student?['enrollment_year'] as String?;
    if (year != null) return year.replaceAll('-', '/');
    return '-';
  }

  String _savingBalance(DashboardData? dashData, SavingsData? savData) {
    if (savData != null) {
      return _formatRupiah.format(savData.balance);
    }
    if (dashData != null) {
      return _formatRupiah.format(dashData.stats.savingBalance);
    }
    return 'Rp -';
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 157,
      width: double.infinity,
      decoration: const BoxDecoration(gradient: _gradient),
      padding: const EdgeInsets.only(top: 24, left: 24, right: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Selamat Datang,',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                const Text('Walisantri',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Container(
                  height: 24,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF22C55E),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Text('Pesantren Modern Ummul Quro Al-Islami',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () =>
                    Navigator.pushNamed(context, '/customer-service'),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.headset_mic_outlined,
                      color: Colors.white, size: 22),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () async {
                  final confirm =
                      await showExitConfirmationDialog(context);
                  if (confirm == true && context.mounted) {
                    await LogoutService.execute(context);
                  }
                },
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.logout,
                      color: Colors.white, size: 22),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.person, color: Colors.white, size: 40),
    );
  }

  Widget _buildProfileCard(
      DashboardData? dashData, Uint8List? photoBytes, Map<String, dynamic>? loginStudent) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: _gradient,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      ClipOval(
                        child: SizedBox(
                          width: 72,
                          height: 72,
                          child: photoBytes != null
                              ? Image.memory(photoBytes,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _buildPhotoPlaceholder())
                              : _buildPhotoPlaceholder(),
                        ),
                      ),
                      Positioned(
                        right: 2,
                        bottom: 2,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: const Color(0xFF22C55E),
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: Colors.white, width: 2.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(_studentName(dashData),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('${_studentClass(dashData)} | ${_studentRoom(dashData)}',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 18),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: BarcodeWidget(
                      barcode: Barcode.code128(),
                      data: _barcodeId(dashData),
                      width: 200,
                      height: 60,
                      drawText: false,
                      color: Colors.black,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('NIS ${_nis(dashData)}',
                      style: const TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontSize: 11,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 1.5)),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF22C55E),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Text('Aktif',
                          style: TextStyle(
                              color: Color(0xFF6B7280), fontSize: 11)),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text('|',
                            style: TextStyle(
                                color: Color(0xFFD1D5DB), fontSize: 12)),
                      ),
                      Text('TA ${_academicYear(dashData)}',
                          style: const TextStyle(
                              color: Color(0xFF6B7280), fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceGrid(DashboardData? dashData, BuildContext context) {
    final items = <Map<String, Object>>[
      {'icon': Icons.school_outlined, 'color': const Color(0xFF7C3AED), 'label': 'Profil', 'route': '/profile'},
      {'icon': Icons.menu_book_outlined, 'color': const Color(0xFFEF4444), 'label': 'Ujian Online', 'route': '/exam'},
      {'icon': Icons.payments_outlined, 'color': const Color(0xFFF97316), 'label': 'Tagihan', 'route': '/bill'},
      {'icon': Icons.history, 'color': const Color(0xFF14B8A6), 'label': 'Histori', 'route': '/history'},
      {'icon': Icons.account_balance_wallet_outlined, 'color': const Color(0xFF22C55E), 'label': 'Tabungan', 'route': '/savings'},
      {'icon': Icons.school_outlined, 'color': const Color(0xFF7C3AED), 'label': 'Rapot Online', 'route': '/report'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.0,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return GestureDetector(
            onTap: () async {
              if (item['route'] == '/profile' || item['route'] == '/bill') {
                await Navigator.pushNamed(context, item['route'] as String,
                    arguments: loginData);
              } else {
                await Navigator.pushNamed(context, item['route'] as String);
              }
              if (context.mounted) {
                context.read<DashboardBloc>().add(DashboardFetch());
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item['icon'] as IconData,
                      color: item['color'] as Color, size: 28),
                  const SizedBox(height: 8),
                  Text(item['label'] as String,
                      style: const TextStyle(
                          color: Color(0xFF1F2937), fontSize: 12),
                      textAlign: TextAlign.center),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnnouncement() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB),
          border: Border.all(color: const Color(0xFFFDE68A)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFFEF3C7),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.notifications_outlined,
                  color: Color(0xFFF59E0B), size: 22),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pengumuman',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF1F2937))),
                  SizedBox(height: 4),
                  Text('Tidak ada pengumuman baru.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomInfo(DashboardData? dashData, SavingsData? savData) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tahun Ajaran',
                      style:
                          TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
                  const SizedBox(height: 6),
                  Text(_academicYear(dashData),
                      style: const TextStyle(
                          color: Color(0xFF1F2937),
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF22C55E),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text('Aktif',
                          style: TextStyle(
                              color: Color(0xFF6B7280), fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Saldo Tabungan',
                      style:
                          TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
                  const SizedBox(height: 6),
                  Text(_savingBalance(dashData, savData),
                      style: const TextStyle(
                          color: Color(0xFF1F2937),
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.monetization_on_outlined,
                          color: Color(0xFF22C55E), size: 14),
                      const SizedBox(width: 6),
                      const Text('Aktif',
                          style: TextStyle(
                              color: Color(0xFF6B7280), fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Utility class for the section title
class _SectionTitle extends StatelessWidget {
  const _SectionTitle();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text('Layanan Digital',
            style: TextStyle(
                color: Color(0xFF1F2937),
                fontSize: 22,
                fontWeight: FontWeight.bold)),
      ),
    );
  }
}


