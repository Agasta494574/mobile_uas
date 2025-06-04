// lib/screen/register_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:mobile_uas/providers/auth_provider.dart';
import 'package:mobile_uas/screen/dashboard_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  // final TextEditingController _nameController = TextEditingController(); // <-- HAPUS BARIS INI

  bool _obscureText = true;

  void _register() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    // String name = _nameController.text.trim(); // <-- HAPUS BARIS INI

    if (email.isEmpty || password.isEmpty) {
      // <-- SESUAIKAN KONDISI VALIDASI INI
      Get.snackbar(
        'Error',
        'Email dan Password harus diisi.',
      ); // <-- SESUAIKAN PESAN ERROR
      return;
    }

    try {
      // Panggil signUp KINI TANPA ARGUMEN 'name'
      bool success = await authProvider.signUp(
        email,
        password,
      ); // <-- HAPUS ARGUMEN 'name'

      if (success) {
        Get.snackbar(
          'Berhasil',
          'Registrasi berhasil! Silakan cek email Anda untuk verifikasi dan login.',
          backgroundColor: Colors.green.shade300,
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.offAll(() => const DashboardScreen());
      } else {
        Get.snackbar(
          'Registrasi Gagal',
          authProvider.errorMessage ?? 'Terjadi kesalahan saat pendaftaran.',
          backgroundColor: Colors.red.shade200,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Registrasi Gagal',
        authProvider.errorMessage ?? 'Terjadi kesalahan saat pendaftaran.',
        backgroundColor: Colors.red.shade200,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    // _nameController.dispose(); // <-- HAPUS BARIS INI
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1FA2FF), Color(0xFF12D8FA), Color(0xFFA6FFCB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/TokoBabe2D.png', height: 140),
                const SizedBox(height: 16),
                Text(
                  'Daftar Akun',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 10,
                  shadowColor: Colors.black26,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // HAPUS TextField untuk 'Nama Lengkap'
                        /*
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.person),
                            labelText: 'Nama Lengkap',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        */
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.email),
                            labelText: 'Email',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscureText,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock),
                            labelText: 'Password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                authProvider.isLoading ? null : _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 6,
                            ),
                            child:
                                authProvider.isLoading
                                    ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                    : const Text(
                                      'DAFTAR',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                      ),
                                    ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text(
                            'Sudah punya akun? Login di sini',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
