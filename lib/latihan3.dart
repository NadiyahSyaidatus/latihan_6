import 'package:flutter/material.dart'; // Import library Flutter untuk membangun UI
import 'dart:convert'; // Import library untuk encoding dan decoding JSON
import 'package:http/http.dart' as http; // Import library untuk melakukan HTTP requests
import 'package:url_launcher/url_launcher.dart'; // Import library untuk membuka URL

void main() {
  runApp(MyApp()); // Memulai aplikasi Flutter
}

// Kelas model untuk merepresentasikan data universitas
class University {
  final String name; // Nama universitas
  final String website; // Website universitas

  University({required this.name, required this.website}); // Konstruktor

  // Metode factory untuk membuat objek University dari JSON
  factory University.fromJson(Map<String, dynamic> json) {
    return University(
      name: json['name'], // Mendapatkan nama universitas dari JSON
      // Mendapatkan website universitas dari JSON,
      // menggunakan website pertama jika ada, jika tidak, mengisi dengan string kosong
      website: json['web_pages'].isEmpty ? "" : json['web_pages'][0],
    );
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState(); // Membuat state untuk aplikasi
}

class _MyAppState extends State<MyApp> {
  late Future<List<University>> futureUniversities; // Menampung hasil dari pemanggilan API

  @override
  void initState() {
    super.initState();
    futureUniversities = fetchUniversities(); // Menginisialisasi futureUniversities dengan data universitas dari server
  }

  // Fungsi untuk mengambil data universitas dari server
  Future<List<University>> fetchUniversities() async {
    try {
      final response = await http.get(Uri.parse('http://universities.hipolabs.com/search?country=Indonesia'));
      if (response.statusCode == 200) {
        // Jika respons dari server adalah 200 OK,
        // parsing data JSON dan mengonversinya menjadi list objek University
        List<dynamic> data = jsonDecode(response.body);
        List<University> universities = data.map((dynamic item) => University.fromJson(item)).toList();
        return universities; // Mengembalikan list universitas
      } else {
        // Jika respons dari server tidak berhasil (bukan 200 OK),
        // lempar exception
        throw Exception('Failed to load universities');
      }
    } catch (e) {
      // Menangani jika gagal terhubung ke server
      throw Exception('Failed to connect to the server.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Indonesian Universities'), // Judul aplikasi
        ),
        body: Center(
          child: FutureBuilder<List<University>>(
            future: futureUniversities, // Menggunakan futureUniversities untuk membangun UI
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // Menampilkan indikator loading jika sedang menunggu data dari server
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                // Menampilkan pesan error jika terjadi kesalahan dalam mengambil data dari server
                return Text("Error: ${snapshot.error}");
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                // Menampilkan pesan jika tidak ada data yang tersedia
                return Text("No data available");
              } else {
                // Jika data tersedia, tampilkan daftar universitas
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        // Menangani ketika item di-tap untuk membuka website universitas
                        _launchURL(snapshot.data![index].website);
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Tampilkan nama universitas
                          ListTile(
                            title: Text(
                              snapshot.data![index].name,
                              textAlign: TextAlign.center,
                            ),
                            // Tampilkan website universitas dengan gaya hyperlink
                            subtitle: Text(
                              snapshot.data![index].website,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          // Tampilkan garis pembatas antar item
                          Divider(
                            color: Colors.grey[300],
                            thickness: 1,
                            height: 0,
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }

  // Fungsi untuk membuka URL universitas
  Future<void> _launchURL(String url) async {
    if (url.isNotEmpty) {
      // Memastikan URL tidak kosong
      if (await canLaunch(url)) {
        // Memeriksa apakah URL dapat dibuka
        await launch(url); // Membuka URL di browser
      } else {
        // Jika tidak dapat membuka URL, lempar exception
        throw 'Could not launch $url';
      }
    } else {
      // Jika URL kosong, lempar exception
      throw 'URL is empty';
    }
  }
}
