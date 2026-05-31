import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/network/api_config.dart';
import '../bloc/exam_bloc.dart';
import '../bloc/exam_event.dart';
import '../bloc/exam_state.dart';

class ExamItem {
  final int id;
  final String title;
  final String subject;
  final String teacherName;
  final String examDate;
  final String startTime;
  final String endTime;
  final int durationMinutes;
  final int questionsCount;
  final String status;
  final double? score;
  final double? totalPoints;
  final String? examUrl;

  const ExamItem({
    required this.id,
    required this.title,
    required this.subject,
    required this.teacherName,
    required this.examDate,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.questionsCount,
    required this.status,
    this.score,
    this.totalPoints,
    this.examUrl,
  });

  factory ExamItem.fromJson(Map<String, dynamic> json) {
    double? parseNum(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }

    int parseInt(dynamic v, int fallback) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? fallback;
      return fallback;
    }

    return ExamItem(
      id: parseInt(json['id'], 0),
      title: json['title'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      teacherName: json['teacher_name'] as String? ?? '',
      examDate: json['exam_date'] as String? ?? '',
      startTime: json['start_time'] as String? ?? '',
      endTime: json['end_time'] as String? ?? '',
      durationMinutes: parseInt(json['duration_minutes'], 0),
      questionsCount: parseInt(json['questions_count'], 0),
      status: json['status'] as String? ?? 'terkunci',
      score: parseNum(json['score']),
      totalPoints: parseNum(json['total_points']),
      examUrl: json['exam_url'] as String?,
    );
  }
}

class ExamScreen extends StatelessWidget {
  const ExamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ExamBloc()..add(ExamFetch()),
      child: const _ExamView(),
    );
  }
}

class _ExamView extends StatefulWidget {
  const _ExamView();

  @override
  State<_ExamView> createState() => _ExamViewState();
}

class _ExamViewState extends State<_ExamView> {
  static const _gradient = LinearGradient(
    colors: [Color(0xFF067A88), Color(0xFF0EA473)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  List<ExamItem> _exams = [];
  String? _token;
  String _activeTab = 'tersedia';

  List<ExamItem> get _filtered =>
      _exams.where((e) => e.status == _activeTab).toList();

  int _countByStatus(String status) =>
      _exams.where((e) => e.status == status).length;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ExamBloc, ExamState>(
      listener: (context, state) {
        if (state is ExamLoaded) {
          setState(() {
            _exams = state.exams
                .map((e) => ExamItem.fromJson(e as Map<String, dynamic>))
                .toList();
            _token = state.token;
          });
        } else if (state is ExamFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is ExamLoading && _exams.isEmpty;
        final error = state is ExamFailure && _exams.isEmpty
            ? state.error
            : null;

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                _buildTabRow(),
                const SizedBox(height: 16),
                _buildSectionLabel(),
                const SizedBox(height: 12),
                Expanded(child: _buildBody(isLoading, error)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back,
                color: Color(0xFF1F2937), size: 22),
          ),
          const SizedBox(width: 12),
          const Text('Ujian Online',
              style: TextStyle(
                  color: Color(0xFF1F2937),
                  fontSize: 18,
                  fontWeight: FontWeight.w600)),
          const Spacer(),
          GestureDetector(
            onTap: () => context.read<ExamBloc>().add(ExamFetch()),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.refresh,
                  size: 18, color: Color(0xFF6B7280)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          _tabItem('tersedia', _countByStatus('tersedia')),
          const SizedBox(width: 10),
          _tabItem('selesai', _countByStatus('selesai')),
          const SizedBox(width: 10),
          _tabItem('terlewat', _countByStatus('terlewat')),
          const SizedBox(width: 10),
          _tabItem('terkunci', _countByStatus('terkunci')),
        ],
      ),
    );
  }

  Widget _tabItem(String status, int count) {
    final isActive = _activeTab == status;
    final label = status[0].toUpperCase() + status.substring(1);

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = status),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: isActive ? _gradient : null,
            color: isActive ? null : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isActive ? Colors.transparent : const Color(0xFFE5E7EB),
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: const Color(0xFF067A88).withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Column(
            children: [
              Text('$count',
                  style: TextStyle(
                      color: isActive
                          ? Colors.white
                          : const Color(0xFF1F2937),
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(label,
                  style: TextStyle(
                      color: isActive
                          ? Colors.white70
                          : const Color(0xFF6B7280),
                      fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text('Mata Pelajaran',
            style: TextStyle(
                color: Color(0xFF1F2937),
                fontSize: 16,
                fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildBody(bool isLoading, String? error) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF0EA473)),
      );
    }
    if (error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_outlined,
                size: 48, color: Color(0xFF9CA3AF)),
            const SizedBox(height: 12),
            Text(error,
                style: const TextStyle(color: Color(0xFF6B7280))),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => context.read<ExamBloc>().add(ExamFetch()),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 10),
                decoration: BoxDecoration(
                  gradient: _gradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('Coba Lagi',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      );
    }
    final items = _filtered;
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _activeTab == 'terkunci'
                  ? Icons.lock_outline
                  : _activeTab == 'selesai'
                      ? Icons.check_circle_outline
                      : _activeTab == 'terlewat'
                          ? Icons.schedule_outlined
                          : Icons.assignment_outlined,
              size: 52,
              color: const Color(0xFFD1D5DB),
            ),
            const SizedBox(height: 12),
            Text('Tidak ada ujian $_activeTab',
                style:
                    const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      color: const Color(0xFF0EA473),
      onRefresh: () async {
        context.read<ExamBloc>().add(ExamFetch());
      },
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) => _buildExamCard(items[index]),
      ),
    );
  }

  Widget _buildExamCard(ExamItem exam) {
    final isTersedia = exam.status == 'tersedia';
    final isSelesai = exam.status == 'selesai';
    final isTerlewat = exam.status == 'terlewat';

    return Container(
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
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F7F5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.menu_book_outlined,
                      color: Color(0xFF0EA473), size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(exam.title,
                          style: const TextStyle(
                              color: Color(0xFF1F2937),
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.person_outline,
                              size: 13, color: Color(0xFF9CA3AF)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(exam.teacherName,
                                style: const TextStyle(
                                    color: Color(0xFF6B7280), fontSize: 12),
                                overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.quiz_outlined,
                              size: 13, color: Color(0xFF9CA3AF)),
                          const SizedBox(width: 4),
                          Text('${exam.questionsCount} Soal',
                              style: const TextStyle(
                                  color: Color(0xFF6B7280), fontSize: 12)),
                          const SizedBox(width: 12),
                          const Icon(Icons.timer_outlined,
                              size: 13, color: Color(0xFF9CA3AF)),
                          const SizedBox(width: 4),
                          Text('${exam.durationMinutes} Menit',
                              style: const TextStyle(
                                  color: Color(0xFF6B7280), fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _buildStatusBadge(exam),
              ],
            ),
          ),
          if (isTersedia) ...[
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFD1FAE5)),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              size: 12, color: Color(0xFF6B7280)),
                          const SizedBox(width: 4),
                          Text(exam.examDate,
                              style: const TextStyle(
                                  color: Color(0xFF6B7280), fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.access_time_outlined,
                              size: 12, color: Color(0xFF6B7280)),
                          const SizedBox(width: 4),
                          Text('${exam.startTime} - ${exam.endTime} WIB',
                              style: const TextStyle(
                                  color: Color(0xFF6B7280), fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _startExam(exam),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 9),
                      decoration: BoxDecoration(
                        gradient: _gradient,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0EA473)
                                .withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Text('mulai',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (isSelesai && exam.score != null) ...[
            const SizedBox(height: 8),
            Container(
              margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events_outlined,
                      size: 16, color: Color(0xFF3B82F6)),
                  const SizedBox(width: 6),
                  Text(
                    'Nilai: ${exam.score!.toStringAsFixed(0)}',
                    style: const TextStyle(
                        color: Color(0xFF3B82F6),
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                  if (exam.totalPoints != null) ...[
                    Text(' / ${exam.totalPoints!.toStringAsFixed(0)}',
                        style: const TextStyle(
                            color: Color(0xFF93C5FD), fontSize: 13)),
                  ],
                ],
              ),
            ),
          ],
          if (isTerlewat) ...[
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              size: 12, color: Color(0xFF6B7280)),
                          const SizedBox(width: 4),
                          Text(exam.examDate,
                              style: const TextStyle(
                                  color: Color(0xFF6B7280), fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.access_time_outlined,
                              size: 12, color: Color(0xFF6B7280)),
                          const SizedBox(width: 4),
                          Text('${exam.startTime} - ${exam.endTime} WIB',
                              style: const TextStyle(
                                  color: Color(0xFF6B7280), fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 9),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning_amber_outlined,
                            size: 14, color: Color(0xFFDC2626)),
                        SizedBox(width: 4),
                        Text('terlewat',
                            style: TextStyle(
                                color: Color(0xFFDC2626),
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (!isTersedia && !isSelesai && !isTerlewat)
            const SizedBox(height: 14),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(ExamItem exam) {
    switch (exam.status) {
      case 'tersedia':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFDCFCE7),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text('tersedia',
              style: TextStyle(
                  color: Color(0xFF16A34A),
                  fontSize: 11,
                  fontWeight: FontWeight.w500)),
        );
      case 'selesai':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFDBEAFE),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            exam.score != null
                ? 'Selesai - ${exam.score!.toStringAsFixed(0)}'
                : 'Selesai',
            style: const TextStyle(
                color: Color(0xFF2563EB),
                fontSize: 11,
                fontWeight: FontWeight.w500),
          ),
        );
      case 'terkunci':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.lock_outline,
                  size: 11, color: Color(0xFF6B7280)),
              SizedBox(width: 3),
              Text('terkunci',
                  style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 11,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        );
      case 'terlewat':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.schedule_outlined,
                  size: 11, color: Color(0xFFDC2626)),
              SizedBox(width: 3),
              Text('terlewat',
                  style: TextStyle(
                      color: Color(0xFFDC2626),
                      fontSize: 11,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _startExam(ExamItem exam) async {
    if (exam.examUrl == null || exam.examUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Link ujian tidak tersedia.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ExamWebViewScreen(
          examTitle: exam.title,
          examUrl: exam.examUrl!,
          token: _token,
        ),
      ),
    );

    if (context.mounted) {
      context.read<ExamBloc>().add(ExamFetch());
    }
  }
}

class _ExamWebViewScreen extends StatefulWidget {
  final String examTitle;
  final String examUrl;
  final String? token;

  const _ExamWebViewScreen({
    required this.examTitle,
    required this.examUrl,
    this.token,
  });

  @override
  State<_ExamWebViewScreen> createState() => _ExamWebViewScreenState();
}

class _ExamWebViewScreenState extends State<_ExamWebViewScreen> {
  late final WebViewController _controller;
  late final Uri _examUri;
  bool _isLoading = true;
  String? _webError;

  @override
  void initState() {
    super.initState();

    _examUri = Uri.parse(widget.examUrl);
    if (!_examUri.isAbsolute) {
      _examUri = Uri.parse('${ApiConfig.baseUrl}${widget.examUrl}');
    }

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (_webError != null) setState(() => _webError = null);
            setState(() => _isLoading = true);
          },
          onPageFinished: (_) => setState(() => _isLoading = false),
          onWebResourceError: (error) {
            setState(() {
              _isLoading = false;
              _webError = 'Gagal memuat ujian. Periksa koneksi Anda.';
            });
          },
          onNavigationRequest: (request) {
            if (request.url.contains('/finish') ||
                request.url.contains('/submit') ||
                request.url.contains('/result')) {
              Navigator.pop(context);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );

    if (widget.token != null) {
      _controller.loadRequest(
        _examUri,
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );
    } else {
      _controller.loadRequest(_examUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF1F2937)),
          onPressed: () => _showExitConfirmation(),
        ),
        title: Text(widget.examTitle,
            style: const TextStyle(
                color: Color(0xFF1F2937),
                fontSize: 16,
                fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          if (_webError != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off_outlined,
                        size: 48, color: Color(0xFF9CA3AF)),
                    const SizedBox(height: 12),
                    Text(_webError!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Color(0xFF6B7280))),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() => _webError = null);
                        _controller.loadRequest(_examUri);
                      },
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            )
          else
            WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFF0EA473)),
            ),
        ],
      ),
    );
  }

  Future<void> _showExitConfirmation() async {
    final exit = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar dari Ujian?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        content: const Text(
          'Jawaban yang sudah tersimpan tidak akan hilang, '
          'tapi waktu ujian tetap berjalan.',
          style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Lanjut Ujian',
                style: TextStyle(color: Color(0xFF6B7280))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Keluar',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (exit == true && mounted) Navigator.pop(context);
  }
}
