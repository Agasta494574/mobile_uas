import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_uas/screen/register_screen.dart'; // Pastikan path ini benar
import 'package:provider/provider.dart';
import 'package:mobile_uas/screen/splash_screen.dart'; // Pastikan path ini benar
import 'package:supabase_flutter/supabase_flutter.dart';
import 'providers/produk_provider.dart'; // Pastikan path ini benar
import 'providers/auth_provider.dart'; // Pastikan path ini benar
import 'providers/transaksi_provider.dart'; // Pastikan path ini benar, dan nama kelasnya TransaksiProvider
import 'package:mobile_uas/screen/login_screen.dart'; // Pastikan path ini benar
import 'package:mobile_uas/screen/dashboard_screen.dart'; // Pastikan path ini benar
import 'package:intl/intl.dart'; // Import IntL
import 'package:intl/date_symbol_data_local.dart'; // Import untuk initializeDateFormatting

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Panggil initializeDateFormatting di awal aplikasi untuk locale 'id'
  await initializeDateFormatting('id', null);

  await Supabase.initialize(
    url: 'https://zmmkvlwjurkercezmvfb.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InptbWt2bHdqdXJrZXJjZXptdmZiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg2ODg5OTUsImV4cCI6MjA2NDI2NDk5NX0.cUQwYK8bpgACxZboVF1ObD4JhItCJJqRR-EXTJUZb_k',
  );

  Intl.defaultLocale = 'id'; // Atur locale default untuk intl

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProdukProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(
          create: (_) => TransaksiProvider(),
        ), // Daftarkan TransaksiProvider
      ],
      child:
          const MyAppWrapper(), // Menggunakan MyAppWrapper untuk navigasi awal
    ),
  );
}

// Tambahkan widget wrapper untuk menangani navigasi awal setelah SplashScreen
class MyAppWrapper extends StatelessWidget {
  const MyAppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aplikasi Toko Kelontong',
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.isLoading) {
            return const SplashScreen(); // Tampilkan SplashScreen saat loading autentikasi
          }

          if (authProvider.isAuthenticated) {
            return const DashboardScreen(); // Jika sudah login, langsung ke Dashboard
          } else {
            return const LoginScreen(); // Jika belum login, tampilkan LoginScreen
          }
        },
      ),
    );
  }
}

// MyApp yang asli tidak lagi perlu home, karena ditangani oleh MyAppWrapper
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aplikasi Toko Kelontong',
      home: const Text('Initialization...'), // Ini hanya placeholder
    );
  }
}
