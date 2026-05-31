import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/models/dashboard_model.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class ProfileScreen extends StatelessWidget {
  final String? loginData;

  const ProfileScreen({super.key, this.loginData});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileBloc()..add(ProfileFetch()),
      child: _ProfileView(loginData: loginData),
    );
  }
}

class _ProfileView extends StatefulWidget {
  final String? loginData;

  const _ProfileView({this.loginData});

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  Map<String, dynamic> _student = {};

  static const _gradient = LinearGradient(
    colors: [Color(0xFF067A88), Color(0xFF0EA473)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  @override
  void initState() {
    super.initState();
    if (widget.loginData != null) {
      try {
        final data = jsonDecode(widget.loginData!);
        _student = (data['student'] as Map<String, dynamic>?) ?? {};
      } catch (_) {}
    }
  }

  Map<String, dynamic> _buildStudentMap(DashboardData? dashData) {
    if (dashData != null) {
      return {
        'name': dashData.student.name,
        'class': dashData.student.studentClass,
        'room': dashData.student.room,
        'barcode_id': dashData.student.barcodeId,
        'nis': dashData.student.nis,
        'nisn': dashData.student.nisn,
        'gender': dashData.student.gender,
        'father_name': dashData.student.fatherName,
        'mother_name': dashData.student.motherName,
        'father_phone': dashData.student.fatherPhone,
        'mother_phone': dashData.student.motherPhone,
        'address': dashData.student.address,
        'status': dashData.student.status,
        'enrollment_year': dashData.student.enrollmentYear,
        'photo_url': dashData.student.photoUrl,
      };
    }
    return _student;
  }

  String _v(Map<String, dynamic> m, String key) =>
      (m[key] as String?) ?? '{{$key}}';

  String _year(Map<String, dynamic> m) {
    final year = m['enrollment_year'] as String?;
    if (year != null) return year.replaceAll('-', '/');
    return '{{academic_year}}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfilePhotoSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.message),
                backgroundColor: const Color(0xFF0EA473)),
          );
        } else if (state is ProfileFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        final dashData =
            state is ProfileLoaded ? state.dashboardData : null;
        final photoBytes =
            state is ProfileLoaded ? state.photoBytes : null;
        final isUploading = state is ProfilePhotoUploading;
        final previewBytes =
            state is ProfilePhotoUploading ? state.previewBytes : null;
        final isLoading = state is ProfileLoading;

        final m = _buildStudentMap(dashData);
        final bytes = previewBytes ?? photoBytes;
        final loadingWidget = isUploading || isLoading;

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: loadingWidget && dashData == null
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFF0EA473)))
                      : SingleChildScrollView(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              const SizedBox(height: 16),
                              _buildProfileCard(m, bytes, isUploading),
                              const SizedBox(height: 16),
                              _buildContactSection(m),
                              const SizedBox(height: 16),
                              _buildDataSantriSection(m),
                              const SizedBox(height: 16),
                              _buildChangePasswordButton(),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChangePasswordButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/change-password'),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline,
                  size: 18, color: Color(0xFF6B7280)),
              const SizedBox(width: 8),
              const Text('Ubah Password',
                  style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
              const Spacer(),
              const Icon(Icons.chevron_right,
                  size: 20, color: Color(0xFF9CA3AF)),
            ],
          ),
        ),
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
          const Text('Profil',
              style: TextStyle(
                  color: Color(0xFF1F2937),
                  fontSize: 18,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildProfileCard(
      Map<String, dynamic> m, Uint8List? photoBytes, bool isUploading) {
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
                  GestureDetector(
                    onTap: isUploading ? null : _showPhotoOptions,
                    child: Stack(
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
                        if (isUploading)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black26,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
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
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: const Color(0xFF067A88),
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.white, width: 1.5),
                            ),
                            child: const Icon(Icons.camera_alt,
                                color: Colors.white, size: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(_v(m, 'name'),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('${_v(m, 'class')} | ${_v(m, 'room')}',
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
                      data: _v(m, 'barcode_id'),
                      width: 200,
                      height: 60,
                      drawText: false,
                      color: Colors.black,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('NIS ${_v(m, 'nis')}',
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
                      Text('TA ${_year(m)}',
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

  Widget _buildContactSection(Map<String, dynamic> m) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildContactItem(
            icon: Icons.phone_outlined,
            label: 'NO WA AYAH',
            value: _v(m, 'father_phone'),
            showDivider: true,
            onTap: () => _showEditDialog(
              title: 'NO WA AYAH',
              currentValue: _v(m, 'father_phone'),
              onSave: (value) => context
                  .read<ProfileBloc>()
                  .add(ProfileUpdateContact(fatherPhone: value)),
            ),
          ),
          _buildContactItem(
            icon: Icons.phone_outlined,
            label: 'NO WA IBU',
            value: _v(m, 'mother_phone'),
            showDivider: true,
            onTap: () => _showEditDialog(
              title: 'NO WA IBU',
              currentValue: _v(m, 'mother_phone'),
              onSave: (value) => context
                  .read<ProfileBloc>()
                  .add(ProfileUpdateContact(motherPhone: value)),
            ),
          ),
          _buildContactItem(
            icon: Icons.home_outlined,
            label: 'Alamat',
            value: _v(m, 'address'),
            showDivider: false,
            onTap: () => _showEditDialog(
              title: 'Alamat',
              currentValue: _v(m, 'address'),
              onSave: (value) => context
                  .read<ProfileBloc>()
                  .add(ProfileUpdateContact(address: value)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String label,
    required String value,
    required bool showDivider,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF6B7280)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 11,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 3),
                    Text(value,
                        style: const TextStyle(
                            color: Color(0xFF1F2937), fontSize: 14)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF0EA473)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Ubah',
                      style: TextStyle(
                          color: Color(0xFF0EA473),
                          fontSize: 13,
                          fontWeight: FontWeight.w500)),
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          const Divider(
              height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
      ],
    );
  }

  Widget _buildDataSantriSection(Map<String, dynamic> m) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Icon(Icons.person_outline,
                    size: 20, color: const Color(0xFF1F2937)),
                const SizedBox(width: 8),
                const Text('Data Santri',
                    style: TextStyle(
                        color: Color(0xFF1F2937),
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
          _buildDataRow('Tahun Masuk', _year(m), showDivider: true),
          _buildDataRow('NISN', _v(m, 'nisn'), showDivider: true),
          _buildDataRow('NIS', _v(m, 'nis'), showDivider: true),
          _buildDataRow('Nama Lengkap', _v(m, 'name'), showDivider: true),
          _buildDataRow('Jenis Kelamin', _v(m, 'gender'),
              showDivider: true, bold: true),
          _buildDataRow('Ayah', _v(m, 'father_name'),
              showDivider: true, bold: true),
          _buildDataRow('Ibu', _v(m, 'mother_name'),
              showDivider: true, bold: true),
          _buildDataRow('Alamat', _v(m, 'address'), showDivider: true),
          _buildDataRow('Status', _v(m, 'status'),
              showDivider: false, bold: true),
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, String value,
      {required bool showDivider, bool bold = false}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Text(label,
                    style: const TextStyle(
                        color: Color(0xFF6B7280), fontSize: 13)),
              ),
              Expanded(
                flex: 5,
                child: Text(value,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        color: const Color(0xFF1F2937),
                        fontSize: 13,
                        fontWeight:
                            bold ? FontWeight.w600 : FontWeight.w400)),
              ),
            ],
          ),
        ),
        if (showDivider)
          const Divider(
              height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
      ],
    );
  }

  Future<void> _showEditDialog({
    required String title,
    required String currentValue,
    required void Function(String) onSave,
  }) async {
    final controller = TextEditingController(text: currentValue);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Ubah $title'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Masukkan $title',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      onSave(result);
    }
    controller.dispose();
  }

  Future<void> _showPhotoOptions() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.photo_outlined,
                    color: Color(0xFF067A88)),
                title: const Text('Ganti Photo'),
                onTap: () => Navigator.pop(ctx, 'ganti'),
              ),
              ListTile(
                leading:
                    const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Hapus Photo',
                    style: TextStyle(color: Colors.red)),
                onTap: () => Navigator.pop(ctx, 'hapus'),
              ),
            ],
          ),
        ),
      ),
    );

    if (result == 'ganti') {
      await _pickAndUploadPhoto();
    } else if (result == 'hapus') {
      _deletePhoto();
    }
  }

  Future<void> _pickAndUploadPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );

    if (picked == null) return;

    final bytes = await picked.readAsBytes();

    context
        .read<ProfileBloc>()
        .add(ProfileUploadPhoto(bytes: bytes, fileName: picked.name));
  }

  Future<void> _deletePhoto() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Photo?'),
        content: const Text(
            'Apakah Anda yakin ingin menghapus photo profil?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      context.read<ProfileBloc>().add(ProfileDeletePhoto());
    }
  }
}
