# 📱 API Documentation — UQI Wali Santri App (Flutter Integration)

**Base URL:** `https://dbs-santriapp.kypau.my.id/api`  
**Auth:** Bearer Token (Laravel Sanctum)  
**Content-Type:** `application/json`

---

## Cara Menggunakan API

### 1. Autentikasi
Semua endpoint yang dilindungi membutuhkan header:
```
Authorization: Bearer {token_dari_login}
Accept: application/json
Content-Type: application/json
```

### 2. Flow Umum Aplikasi
```
Login → Verify OTP → Dashboard → Fitur (Bills, Payments, Savings, Exams, Reports)
```

### 3. Error Handling
Semua error mengikuti format:
```json
{
  "success": false,
  "message": "Deskripsi error dalam Bahasa Indonesia."
}
```

| HTTP Code | Arti |
|-----------|------|
| `200` | Sukses |
| `201` | Data berhasil dibuat |
| `400` | Request tidak valid |
| `401` | Belum login / token expired |
| `403` | Tidak punya akses |
| `404` | Data tidak ditemukan |
| `422` | Validasi gagal (lihat `errors` object) |
| `500` | Server error |

---

## 🔐 Authentication

### POST `/login`
Login via nama santri (case-insensitive) atau NIS.

**Request:**
```json
{
  "identifier": "umar abdullah",
  "password": "password123"
}
```
> `identifier` bisa berupa nama santri (huruf besar/kecil bebas) atau NIS seperti `"2024005"`

**Response 200:**
```json
{
  "success": true,
  "message": "Login berhasil.",
  "data": {
    "user": {
      "id": 1,
      "name": "Umar Abdullah",
      "role": "walisantri"
    },
    "student": {
      "id": 5,
      "name": "Umar Abdullah",
      "nis": "2024005",
      "class": "3A-PA"
    },
    "token": "1|abc123def456..."
  }
}
```

**Response 401:**
```json
{
  "success": false,
  "message": "Password salah."
}
```

**Contoh Flutter (Dart):**
```dart
final response = await http.post(
  Uri.parse('$baseUrl/login'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({
    'identifier': 'umar abdullah',
    'password': 'password123',
  }),
);
final data = jsonDecode(response.body);
final token = data['data']['token']; // simpan di SharedPreferences
```

---

### POST `/register`
Daftarkan wali santri baru (harus cocok dengan data santri yang sudah ada di sistem).

**Request:**
```json
{
  "student_name": "umar abdullah",
  "nis": "2024005",
  "phone": "085678901234",
  "password": "password123",
  "password_confirmation": "password123"
}
```

**Response 201:**
```json
{
  "success": true,
  "message": "Registrasi berhasil. Silakan verifikasi OTP.",
  "data": {
    "user": { "id": 10, "name": "Umar Abdullah" },
    "student": { "id": 5, "name": "Umar Abdullah" },
    "token": "2|xyz789...",
    "requires_otp": true
  }
}
```

---

### POST `/verify-otp`
Verifikasi kode OTP yang dikirim ke WhatsApp.

**Headers:** `Authorization: Bearer {token}`

**Request:**
```json
{
  "otp": "123456"
}
```

**Response 200:**
```json
{
  "success": true,
  "message": "Nomor HP berhasil diverifikasi."
}
```

---

### POST `/resend-otp`
Kirim ulang kode OTP.

**Headers:** `Authorization: Bearer {token}`

**Response 200:**
```json
{
  "success": true,
  "message": "Kode OTP baru telah dikirim."
}
```

---

### POST `/logout`
Hapus token saat ini.

**Headers:** `Authorization: Bearer {token}`

**Response 200:**
```json
{
  "success": true,
  "message": "Logout berhasil."
}
```

---

### GET `/user`
Data user yang sedang login.

**Headers:** `Authorization: Bearer {token}`

**Response 200:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "Umar Abdullah",
    "role": "walisantri",
    "phone_verified": true,
    "student": {
      "id": 5,
      "name": "Umar Abdullah",
      "nis": "2024005",
      "class": "3A-PA"
    }
  }
}
```

---

## 🏠 Dashboard

### GET `/dashboard`
Ringkasan lengkap data santri — cocok untuk halaman utama Flutter.

**Headers:** `Authorization: Bearer {token}`

**Response 200:**
```json
{
  "success": true,
  "data": {
    "student": {
      "id": 5,
      "name": "Umar Abdullah",
      "nis": "2024005",
      "nisn": "0071234571",
      "class": "3A-PA",
      "room": "A5",
      "gender": "L",
      "father_name": "Abdullah Mansur",
      "mother_name": "Maryam Abdullah",
      "father_phone": "085678901234",
      "mother_phone": "085678901235",
      "address": "Jl. Merdeka No. 10",
      "photo_url": "https://dbs-santriapp.kypau.my.id/storage/photos/students/xxx.jpg",
      "enrollment_year": "2022-2023",
      "birth_date": "2010-05-15",
      "barcode_id": "WS-2024005"
    },
    "stats": {
      "pending_bills": 9,
      "total_paid": 2650000,
      "total_paid_formatted": "Rp 2.650.000",
      "saving_balance": 423673,
      "saving_balance_formatted": "Rp 423.673",
      "upcoming_exams": 3
    },
    "recent_bills": [
      {
        "id": 1,
        "title": "SPP Januari 2024",
        "amount": 500000,
        "paid_amount": 0,
        "remaining": 500000,
        "due_date": "2024-01-31",
        "status": "pending"
      }
    ],
    "recent_payments": [
      {
        "id": 1,
        "bill_title": "SPP Desember 2023",
        "amount": 500000,
        "payment_method": "Virtual Account",
        "paid_at": "2024-01-15 10:30"
      }
    ],
    "upcoming_exams": [
      {
        "id": 2,
        "title": "UAS Fiqih",
        "subject": "Fiqih",
        "teacher_name": "Ustadzah Maryam",
        "exam_date": "2026-05-20",
        "duration_minutes": 60,
        "questions_count": 5,
        "pivot_status": "not_started",
        "exam_url": "https://dbs-santriapp.kypau.my.id/exams/join/abc123token..."
      }
    ]
  }
}
```

---

## 👤 Profile

### GET `/profile`
Data lengkap santri.

**Headers:** `Authorization: Bearer {token}`

### PUT `/profile`
Update data kontak (field yang boleh diubah oleh wali).

**Headers:** `Authorization: Bearer {token}`

**Request:**
```json
{
  "father_phone": "081234567890",
  "mother_phone": "081234567891",
  "address": "Jl. Merdeka No. 1"
}
```

**Response 200:**
```json
{
  "success": true,
  "message": "Data profil berhasil diperbarui.",
  "data": { "...student data..." }
}
```

---

### GET `/profile/photo`
Download foto santri (response berupa binary image, bukan JSON).

### POST `/profile/photo`
Upload / ganti foto santri.

**Headers:** `Authorization: Bearer {token}`  
**Content-Type:** `multipart/form-data`

| Field | Type | Wajib | Keterangan |
|-------|------|-------|------------|
| `photo` | file | Ya | jpeg/jpg/png/webp, max 2MB |

**Response 200:**
```json
{
  "success": true,
  "message": "Foto berhasil diupload.",
  "data": {
    "photo_path": "photos/students/abc123.jpg",
    "photo_url": "https://dbs-santriapp.kypau.my.id/storage/photos/students/abc123.jpg"
  }
}
```

**Contoh Flutter (Dart):**
```dart
var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/profile/photo'));
request.headers['Authorization'] = 'Bearer $token';
request.files.add(await http.MultipartFile.fromPath('photo', filePath));
var response = await request.send();
```

---

### POST `/change-password`
Ganti password akun.

**Headers:** `Authorization: Bearer {token}`

**Request:**
```json
{
  "current_password": "oldpass123",
  "new_password": "newpass456",
  "new_password_confirmation": "newpass456"
}
```

---

## 💰 Bills (Tagihan)

### GET `/bills`
Daftar semua tagihan santri (pending dulu, lalu paid).

**Headers:** `Authorization: Bearer {token}`

**Response 200:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "title": "SPP Januari 2024",
      "amount": 500000,
      "paid_amount": 0,
      "remaining": 500000,
      "status": "pending",
      "due_date": "2024-01-31",
      "formatted_amount": "Rp 500.000",
      "formatted_remaining": "Rp 500.000"
    },
    {
      "id": 2,
      "title": "SPP Desember 2023",
      "amount": 500000,
      "paid_amount": 500000,
      "remaining": 0,
      "status": "paid",
      "due_date": "2023-12-31"
    }
  ]
}
```

---

### GET `/bills/{id}`
Detail tagihan lengkap + riwayat pembayarannya.

**Headers:** `Authorization: Bearer {token}`

**Response 200:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "title": "SPP Januari 2024",
    "description": "Sumbangan Pembinaan Pendidikan bulan Januari",
    "amount": 500000,
    "paid_amount": 0,
    "remaining": 500000,
    "due_date": "2024-01-31",
    "status": "pending",
    "type": "monthly",
    "payments": [
      {
        "id": 5,
        "amount": 250000,
        "payment_method": "Virtual Account",
        "transaction_id": "WS-1-1716...",
        "status": "success",
        "paid_at": "2024-01-10 14:30"
      }
    ],
    "created_at": "2024-01-01 00:00"
  }
}
```

---

### POST `/bills/pay` ⭐ Midtrans Integration
Buat transaksi pembayaran via Midtrans. Mengembalikan `snap_token` dan `redirect_url`.

**Headers:** `Authorization: Bearer {token}`

**Request:**
```json
{
  "bill_id": 1,
  "amount": 500000
}
```

**Response 200:**
```json
{
  "success": true,
  "message": "Token pembayaran berhasil dibuat.",
  "data": {
    "snap_token": "66e4fa55-fdac-4ef...",
    "redirect_url": "https://app.sandbox.midtrans.com/snap/v3/redirection/66e4fa55...",
    "order_id": "WS-1-1716123456-ABCD",
    "payment_id": 15,
    "amount": 500000
  }
}
```

**Cara Pakai di Flutter:**

```dart
// OPSI 1: Buka redirect_url di WebView (RECOMMENDED)
import 'package:webview_flutter/webview_flutter.dart';

void payBill(Map<String, dynamic> snapData) {
  Navigator.push(context, MaterialPageRoute(
    builder: (_) => Scaffold(
      appBar: AppBar(title: Text('Pembayaran')),
      body: WebViewWidget(
        controller: WebViewController()
          ..loadRequest(Uri.parse(snapData['redirect_url']))
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(NavigationDelegate(
            onNavigationRequest: (request) {
              // Detect finish URL
              if (request.url.contains('/midtrans/finish')) {
                Navigator.pop(context);
                _checkPaymentStatus(snapData['order_id']);
                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            },
          )),
      ),
    ),
  ));
}

// OPSI 2: Buka di browser external
import 'package:url_launcher/url_launcher.dart';

await launchUrl(Uri.parse(snapData['redirect_url']));
```

**Metode Pembayaran yang Tersedia:**
| Kategori | Metode |
|----------|--------|
| Kartu Debit/Credit | Visa, Mastercard, JCB |
| Virtual Account | BCA, BNI, BRI, Permata, Mandiri Bill |
| E-Wallet | GoPay, ShopeePay |
| QRIS | Semua bank & e-wallet |
| Mitra/Agen | Indomaret, Alfamart |

---

### POST `/bills/check-status`
Cek status pembayaran setelah user selesai di halaman Midtrans.

**Headers:** `Authorization: Bearer {token}`

**Request:**
```json
{
  "order_id": "WS-1-1716123456-ABCD"
}
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "order_id": "WS-1-1716123456-ABCD",
    "status": "success",
    "amount": 500000,
    "payment_method": "Virtual Account",
    "paid_at": "2024-01-15 10:30"
  }
}
```

**Status Values:** `pending` | `success` | `failed` | `expire`

**Flow Pembayaran Lengkap di Flutter:**
```
1. POST /bills/pay → dapat snap_token & redirect_url
2. Buka redirect_url di WebView
3. User pilih metode & bayar di halaman Midtrans
4. Setelah selesai, panggil POST /bills/check-status
5. Jika status = "success" → refresh bills
6. Jika status = "pending" → tampilkan "Menunggu konfirmasi"
```

---

### GET `/bills/history/paid`
Tagihan yang sudah lunas saja.

---

## 💳 Payments (Riwayat Pembayaran)

### GET `/payments`
Semua riwayat pembayaran (paginated, 20/halaman).

**Headers:** `Authorization: Bearer {token}`

**Query Params:** `?page=1`

**Response 200:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "bill_title": "SPP Januari 2024",
      "amount": 500000,
      "payment_method": "Virtual Account",
      "transaction_id": "WS-1-1716123456-ABCD",
      "status": "success",
      "paid_at": "2024-01-15 10:30"
    }
  ],
  "meta": {
    "current_page": 1,
    "last_page": 3,
    "per_page": 20,
    "total": 45
  }
}
```

### GET `/payments/{id}`
Detail satu transaksi pembayaran.

---

## 🐷 Savings (Tabungan)

### GET `/savings`
Saldo tabungan santri.

**Headers:** `Authorization: Bearer {token}`

**Response 200:**
```json
{
  "success": true,
  "data": {
    "balance": 423673,
    "formatted_balance": "Rp 423.673"
  }
}
```

### POST `/savings/topup` ⭐ Midtrans Integration
Top up saldo tabungan melalui Midtrans. Mengembalikan `snap_token` dan `redirect_url`.

**Headers:** `Authorization: Bearer {token}`

**Request:**
```json
{
  "amount": 50000,
  "description": "Uang saku mingguan"
}
```

**Response 200:**
```json
{
  "success": true,
  "message": "Token pembayaran berhasil dibuat.",
  "data": {
    "snap_token": "8ea3f2b1-5a2a-4c2...",
    "redirect_url": "https://app.sandbox.midtrans.com/snap/v3/redirection/8ea3f2b1...",
    "order_id": "SAV-13-1716123456-ABCD",
    "transaction": {
      "id": 1,
      "type": "topup",
      "amount": 50000,
      "description": "Uang saku mingguan",
      "transaction_id": "SAV-13-1716123456-ABCD",
      "balance_after": 473673,
      "status": "pending",
      "created_at": "2024-05-19 14:00"
    }
  }
}
```

> ⚠️ **Catatan Flow Flutter:**
> Flow pembayaran tabungan persis sama dengan tagihan (bills). Buka `redirect_url` di WebView dan tunggu return ke `/midtrans/finish`. Saldo tabungan (balance) akan bertambah secara otomatis di *background* melalui webhook Midtrans saat pembayaran `success`.

### GET `/savings/history`
Riwayat transaksi tabungan (paginated).

**Headers:** `Authorization: Bearer {token}`

---

## 📝 Exams (Ujian Online)

### GET `/exams`
Daftar ujian yang ditugaskan ke santri beserta status dan link unik.

**Headers:** `Authorization: Bearer {token}`

**Response 200:**
```json
{
  "success": true,
  "data": [
    {
      "id": 2,
      "title": "UAS Fiqih Semester 2",
      "subject": "Fiqih",
      "description": "Ujian akhir semester genap",
      "teacher_name": "Ustadzah Maryam",
      "exam_date": "2026-05-20",
      "start_time": "08:00",
      "end_time": "10:00",
      "duration_minutes": 60,
      "questions_count": 25,
      "status": "tersedia",
      "score": null,
      "total_points": null,
      "started_at": null,
      "finished_at": null,
      "exam_url": "https://dbs-santriapp.kypau.my.id/exams/join/F1ahaL13FBQ...",
      "access_token": "F1ahaL13FBQ..."
    }
  ]
}
```

**Status Label:**
| Status | Arti | Warna |
|--------|------|-------|
| `tersedia` | Bisa dikerjakan sekarang | 🟢 Hijau |
| `selesai` | Sudah dikerjakan (ada score) | 🔵 Biru |
| `terkunci` | Belum waktunya / ujian draft | 🔒 Abu-abu |
| `terlewat` | Waktu sudah habis, belum dikerjakan | 🔴 Merah |

> `exam_url` hanya muncul jika status = `tersedia`. Buka URL ini di WebView untuk mengerjakan ujian.

---

### POST `/exams/start`
Mulai ujian dan ambil soal-soal (tanpa kunci jawaban).

**Headers:** `Authorization: Bearer {token}`

**Request:**
```json
{
  "exam_id": 2
}
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "exam": {
      "id": 2,
      "title": "UAS Fiqih",
      "duration_minutes": 60
    },
    "remaining_seconds": 3600,
    "access_token": "F1ahaL13FBQ...",
    "questions": [
      {
        "id": 10,
        "question_text": "Berapa jumlah rukun Islam?",
        "question_type": "multiple_choice",
        "options": [
          {"key": "A", "text": "3"},
          {"key": "B", "text": "4"},
          {"key": "C", "text": "5"},
          {"key": "D", "text": "6"}
        ],
        "points": 10,
        "your_answer": null
      },
      {
        "id": 12,
        "question_text": "Sebutkan syarat-syarat sah shalat!",
        "question_type": "essay",
        "options": null,
        "points": 20,
        "your_answer": null
      }
    ]
  }
}
```

> ⚠️ **Kunci jawaban TIDAK pernah dikirim** ke frontend untuk keamanan.

---

### POST `/exams/save-answer`
Auto-save jawaban per soal (panggil setiap kali user menjawab).

**Headers:** `Authorization: Bearer {token}`

**Request:**
```json
{
  "exam_id": 2,
  "question_id": 10,
  "answer_text": "C",
  "access_token": "F1ahaL13FBQ..."
}
```

**Response 200:**
```json
{
  "success": true,
  "message": "Jawaban tersimpan."
}
```

---

### POST `/exams/submit`
Kumpulkan ujian. Soal PG otomatis dinilai, essay dinilai manual oleh admin.

**Headers:** `Authorization: Bearer {token}`

**Request:**
```json
{
  "exam_id": 2
}
```

**Response 200:**
```json
{
  "success": true,
  "message": "Ujian berhasil dikumpulkan.",
  "data": {
    "score": 85.5,
    "total_points": 100
  }
}
```

---

### GET `/exams/result?exam_id=2`
Lihat hasil ujian setelah selesai.

**Headers:** `Authorization: Bearer {token}`

---

## 📊 Reports (Raport)

### GET `/reports`
Daftar raport yang sudah dipublish.

### GET `/reports/{id}`
Detail raport (nilai per mata pelajaran, rata-rata, peringkat).

**Response 200:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "semester": "Ganjil",
    "academic_year": "2023-2024",
    "grades": { "Fiqih": 90, "Bahasa Arab": 85, "Tahfidz": 95 },
    "average_score": 90.0,
    "rank": 3,
    "notes": "Santri aktif dan rajin.",
    "published_at": "2024-01-20"
  }
}
```

### GET `/reports/download/{id}`
Download raport dalam format PDF (binary response).

---

## 🔗 Ujian via WebView (Flutter → Web)

### Alur Lengkap:
```
1. GET /exams → dapat daftar ujian + exam_url
2. Buka exam_url di WebView (auto-login via token)
3. Siswa mengerjakan ujian di web (anti-cheat aktif)
4. Setelah submit/waktu habis → auto-close
5. GET /exams → refresh, status berubah "selesai" + score
```

**Contoh Flutter Code:**
```dart
import 'package:webview_flutter/webview_flutter.dart';

class ExamWebView extends StatelessWidget {
  final String examUrl;
  
  const ExamWebView({required this.examUrl});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebViewWidget(
        controller: WebViewController()
          ..loadRequest(Uri.parse(examUrl))
          ..setJavaScriptMode(JavaScriptMode.unrestricted),
      ),
    );
  }
}

// Panggil:
Navigator.push(context, MaterialPageRoute(
  builder: (_) => ExamWebView(examUrl: exam['exam_url']),
));
```

**Keamanan Token Ujian:**
| Aspek | Detail |
|-------|--------|
| Panjang | 48 karakter random |
| Unik per | Setiap siswa × setiap ujian |
| Auto-login | Ya, token = identitas siswa |
| Validasi | Cek student ownership, exam aktif, waktu valid |
| Anti-share | Token dicek terhadap akun yang login |

---

## 🔑 Demo Credentials

| Nama Santri | NIS | Password |
|-------------|-----|----------|
| Muhammad Rizki Fauzi | 2024001 | password |
| Aisyah Putri Nuraini | 2024002 | password |
| Fajar Ramadhan | 2024003 | password |
| Nur Hidayah | 2024004 | password |
| Umar Abdullah | 2024005 | password |

**Admin:** username `admin`, password `admin123`

> Login bisa menggunakan nama (case-insensitive) atau NIS

---

## ⚙️ Midtrans Webhook Configuration

Agar pembayaran otomatis memotong tagihan, konfigurasi **Payment Notification URL** di Midtrans Dashboard:

1. Buka [Midtrans Sandbox Dashboard](https://dashboard.sandbox.midtrans.com) → **Settings → Configuration**
2. Set **Payment Notification URL**:
   ```
   https://dbs-santriapp.kypau.my.id/midtrans/notification
   ```
3. Klik **Save**

### Webhook Flow:
```
User bayar → Midtrans proses → POST /midtrans/notification → Server update payment + bill → Tagihan terpotong
```

### Sandbox Test Cards:
| Keterangan | Nomor Kartu | CVV | Exp |
|---|---|---|---|
| ✅ Sukses (Visa) | `4811 1111 1111 1114` | `123` | `01/29` |
| ✅ Sukses (Mastercard) | `5211 1111 1111 1117` | `123` | `01/29` |
| ❌ Ditolak | `4911 1111 1111 1113` | `123` | `01/29` |

> OTP/3DS Password: `112233`