import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_uas/screen/register_screen.dart';
import 'package:provider/provider.dart';
import 'package:mobile_uas/screen/splash_screen.dart'; // Correct path
import 'package:supabase_flutter/supabase_flutter.dart';
import 'providers/produk_provider.dart';
import 'providers/auth_provider.dart'; // Correct path
import 'providers/transaksi_provider.dart';
import 'package:mobile_uas/screen/login_screen.dart'; // Correct path
import 'package:mobile_uas/screen/dashboard_screen.dart'; // Correct path
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('id', null);

  await Supabase.initialize(
    url: 'https://zmmkvlwjurkercezmvfb.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InptbWt2bHdqdXJrZXJjZXptdmZiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg2ODg5OTUsImV4cCI6MjA2NDI2NDk5NX0.cUQwYK8bpgACxZboVF1ObD4JhItCJJqRR-EXTJUZb_k',
  );

  Intl.defaultLocale = 'id';

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProdukProvider()),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ), // `AuthProvider` is used for authentication
        ChangeNotifierProvider(create: (_) => TransaksiProvider()),
      ],
      child: const MyApp(), // Set MyApp as the entry point
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aplikasi Toko Kelontong',
      // The initial screen should be SplashScreen
      home: const SplashScreen(),
    );
  }
}
