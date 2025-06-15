import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mobile_uas/providers/stock_movment_provider.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Penting: Pastikan ini diimpor
import 'package:mobile_uas/providers/auth_provider.dart';
import 'package:mobile_uas/providers/produk_provider.dart';
import 'package:mobile_uas/providers/transaksi_provider.dart';
import 'package:mobile_uas/screen/splash_screen.dart'; // Atau halaman awal Anda

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('id', null);

  await Supabase.initialize(
    url: 'https://zmmkvlwjurkercezmvfb.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InptbWt2bHdqdXJrZXJjZXptdmZiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg2ODg5OTUsImV4cCI6MjA2NDI2NDk5NX0.cUQwYK8bpgACxZboVF1ObD4JhItCJJqRR-EXTJUZb_k', // Ganti dengan anon key Supabase Anda
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProdukProvider()),
        ChangeNotifierProvider(create: (_) => TransaksiProvider()),
        ChangeNotifierProvider(
          create: (_) => StockMovementProvider(),
        ), // <--- BARU
      ],
      child: GetMaterialApp(
        title: 'Toko Babe',
        theme: ThemeData(
          primarySwatch: Colors.teal,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
