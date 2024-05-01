import 'dart:convert'; // Import library dart:convert untuk pengolahan JSON

void main() {
  // Data JSON yang disimpan sebagai string
  String jsonString = '''
  {
    "mahasiswa": {
      "Nama": "Nadiyah Syaidatus",
      "NPM" : "22082010038",
      "Prodi": "Sistem Informasi",
      "Perguruan Tinggi": "UPN Veteran Jawa Timur"
    },
    "transkrip": [
      {
        "kode_mk": "PM04",
        "nama_mk": "Pemprograman Mobile",
        "sks": 3,
        "nilai": "A"
      },
      {
        "kode_mk": "PW04",
        "nama_mk": "Pemprograman Web",
        "sks": 3,
        "nilai": "A"
      },
      {
        "kode_mk": "PD03",
        "nama_mk": "Pemrograman Dekstop",
        "sks": 3,
        "nilai": "A-"
      },
      {
        "kode_mk": "BD02",
        "nama_mk": "Basis Data",
        "sks": 3,
        "nilai": "B+"
      }
    ]
  }
  ''';

  // Menguraikan JSON ke dalam objek Map untuk memudahkan akses data
  Map<String, dynamic> parsedJson = jsonDecode(jsonString);

  // Mengakses array transkrip dari JSON
  List<dynamic> transkrip = parsedJson['transkrip'];

  double totalNilai = 0.0;
  int totalSks = 0;

  // Fungsi untuk mengonversi nilai huruf ke angka
  double nilaiKeAngka(String nilai) {
    switch (nilai) {
      case 'A':
        return 4.0;
      case 'A-':
        return 3.7;
      case 'B+':
        return 3.3;
      case 'B':
        return 3.0;
      case 'B-':
        return 2.7;
      case 'C+':
        return 2.3;
      case 'C':
        return 2.0;
      case 'D':
        return 1.0;
      default:
        return 0.0; // untuk nilai yang tidak dikenal atau gagal
    }
  }

  // Perhitungan total nilai dan total SKS
  for (var mataKuliah in transkrip) {
    int sks = mataKuliah['sks']; // Mendapatkan jumlah SKS dari setiap mata kuliah
    String nilai = mataKuliah['nilai']; // Mendapatkan nilai huruf dari setiap mata kuliah
    totalSks += sks; // Menambahkan jumlah SKS ke total SKS
    totalNilai += nilaiKeAngka(nilai) * sks; // Menambahkan nilai per SKS ke total nilai
  }

  // Menghitung IPK
  double ipk = totalNilai / totalSks;

  // Menampilkan IPK
  print(
      "IPK dari ${parsedJson['mahasiswa']['Nama']} adalah ${ipk.toStringAsFixed(2)}");
}
