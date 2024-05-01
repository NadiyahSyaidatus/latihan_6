import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

// Kelas model untuk menampung data aktivitas
class Activity {
  String aktivitas;
  String jenis;

  Activity({required this.aktivitas, required this.jenis}); // Konstruktor

  // Konstruktor dari JSON ke atribut
  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      aktivitas: json['activity'],
      jenis: json['type'],
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  late Future<Activity> futureActivity; // Menampung hasil dari pemanggilan API
  String url = "https://www.boredapi.com/api/activity"; // URL endpoint API

  // Inisialisasi futureActivity dengan data kosong
  Future<Activity> init() async {
    return Activity(aktivitas: "", jenis: "");
  }

  // Mengambil data dari API
  Future<Activity> fetchData() async {
    final response = await http.get(Uri.parse(url)); // Mengirim permintaan GET ke API
    if (response.statusCode == 200) {
      // Jika respons dari server adalah 200 OK
      // Parse JSON dan konversi menjadi objek Activity
      return Activity.fromJson(jsonDecode(response.body));
    } else {
      // Jika respons dari server bukan 200 OK, lempar exception
      throw Exception('Gagal load');
    }
  }

  @override
  void initState() {
    super.initState();
    futureActivity = init(); // Menginisialisasi futureActivity dengan data kosong
  }

  @override
  Widget build(Object context) {
    return MaterialApp(
        home: Scaffold(
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          // Tombol untuk memuat aktivitas baru
          Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: ElevatedButton(
              onPressed: () {
                // Ketika tombol ditekan, memuat aktivitas baru
                setState(() {
                  futureActivity = fetchData();
                });
              },
              child: Text("Saya bosan ..."),
            ),
          ),
          // Menampilkan hasil aktivitas yang telah dimuat
          FutureBuilder<Activity>(
            future: futureActivity,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                // Jika snapshot memiliki data, tampilkan aktivitas
                return Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      Text(snapshot.data!.aktivitas),
                      Text("Jenis: ${snapshot.data!.jenis}")
                    ]));
              } else if (snapshot.hasError) {
                // Jika terjadi error, tampilkan pesan error
                return Text('${snapshot.error}');
              }
              // Jika tidak ada data dan tidak ada error, tampilkan indikator loading
              return const CircularProgressIndicator();
            },
          ),
        ]),
      ),
    ));
  }
}
