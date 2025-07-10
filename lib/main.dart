// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart'; // <-- 1. TAMBAHKAN IMPORT INI
import 'firebase_options.dart';
import 'screens/home_screen.dart';

void main() async {
  // Pastikan semua plugin siap sebelum aplikasi berjalan
  WidgetsFlutterBinding.ensureInitialized();

  // ===================================================================
  // 2. TAMBAHKAN BARIS INISIALISASI DI SINI
  // Memuat data lokalisasi untuk Bahasa Indonesia ('id_ID')
  await initializeDateFormatting('id_ID', null);
  // ===================================================================

  // Inisialisasi Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DompetKu Pribadi',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}