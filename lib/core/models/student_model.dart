class StudentModel {
  final int id;
  final int userId;
  final String name;
  final String nis;
  final String nisn;
  final String studentClass;
  final String room;
  final String enrollmentYear;
  final String fatherName;
  final String motherName;
  final String fatherPhone;
  final String motherPhone;
  final String barcodeId;
  final String photo;
  final String photoUrl;
  final String birthDate;
  final String gender;
  final String address;
  final String status;
  final bool isClaimed;
  final String createdAt;

  const StudentModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.nis,
    required this.nisn,
    required this.studentClass,
    required this.room,
    required this.enrollmentYear,
    required this.fatherName,
    required this.motherName,
    required this.fatherPhone,
    required this.motherPhone,
    required this.barcodeId,
    required this.photo,
    required this.photoUrl,
    required this.birthDate,
    required this.gender,
    required this.address,
    required this.status,
    required this.isClaimed,
    required this.createdAt,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      name: json['name'] as String,
      nis: json['nis'] as String,
      nisn: json['nisn'] as String,
      studentClass: json['class'] as String,
      room: json['room'] as String? ?? '',
      enrollmentYear: json['enrollment_year'] as String,
      fatherName: json['father_name'] as String? ?? '',
      motherName: json['mother_name'] as String? ?? '',
      fatherPhone: json['father_phone'] as String? ?? '',
      motherPhone: json['mother_phone'] as String? ?? '',
      barcodeId: json['barcode_id'] as String? ?? '',
      photo: json['photo'] as String? ?? '',
      photoUrl: json['photo_url'] as String? ?? '',
      birthDate: json['birth_date'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      address: json['address'] as String? ?? '',
      status: json['status'] as String? ?? '',
      isClaimed: json['is_claimed'] as bool? ?? false,
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'nis': nis,
      'nisn': nisn,
      'class': studentClass,
      'room': room,
      'enrollment_year': enrollmentYear,
      'father_name': fatherName,
      'mother_name': motherName,
      'father_phone': fatherPhone,
      'mother_phone': motherPhone,
      'barcode_id': barcodeId,
      'photo': photo,
      'photo_url': photoUrl,
      'birth_date': birthDate,
      'gender': gender,
      'address': address,
      'status': status,
      'is_claimed': isClaimed,
      'created_at': createdAt,
    };
  }
}
