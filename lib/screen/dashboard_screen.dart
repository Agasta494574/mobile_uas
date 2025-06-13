// lib/screen/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:provider/provider.dart';

import 'package:mobile_uas/screen/login_screen.dart';
import 'package:mobile_uas/screen/dashboard_home.dart';
import 'package:mobile_uas/screen/produk_screen.dart';
import 'package:mobile_uas/screen/transaksi_screen.dart';
import 'package:mobile_uas/screen/laporan_screen.dart';
import 'package:mobile_uas/screen/akun_screen.dart';
import 'package:mobile_uas/providers/auth_provider.dart';
import 'package:mobile_uas/model/user.dart'
    as AppUser; // Import alias untuk User model

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 2; // Home di tengah (index ke-2)

  final iconList = <IconData>[
    Icons.inventory_2, // Produk (index 0)
    Icons.receipt_long, // Transaksi (index 1)
    Icons.bar_chart, // Laporan (index 2)
    Icons.person, // Akun (index 3)
  ];

  final List<Widget> pages = [
    const ProdukScreen(), // 0
    const TransaksiScreen(), // 1
    const DashboardHome(), // 2 (Home screen)
    const LaporanScreen(), // 3
    const AkunScreen(), // 4
  ];

  // Penyesuaian judul AppBar berdasarkan index
  String _getAppBarTitle(int index, AppUser.User? currentUser) {
    if (index == 2) {
      // Jika halaman Beranda
      return currentUser?.username ?? 'Toko Babe';
    } else if (index == 0) {
      return 'Produk';
    } else if (index == 1) {
      return 'Transaksi';
    } else if (index == 3) {
      return 'Laporan';
    } else if (index == 4) {
      return 'Akun';
    }
    return 'Dashboard'; // Default
  }

  void _logout() async {
    try {
      await Provider.of<AuthProvider>(context, listen: false).signOut();
      if (!mounted) return;

      Get.offAll(() => const LoginScreen());
      Get.snackbar(
        'Logout',
        'Anda berhasil logout',
        backgroundColor: Colors.green.shade300,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      if (!mounted) return;

      Get.snackbar(
        'Error Logout',
        'Terjadi kesalahan saat logout: $e',
        backgroundColor: Colors.red.shade200,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final AppUser.User? currentUser = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getAppBarTitle(_currentIndex, currentUser),
        ), // Judul dinamis
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        actions:
            _currentIndex ==
                    4 // Tombol logout hanya di halaman Akun
                ? [
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: _logout,
                    tooltip: 'Logout',
                  ),
                ]
                : (_currentIndex ==
                        2 // Tombol notifikasi hanya di halaman Beranda
                    ? [
                      IconButton(
                        icon: const Icon(Icons.notifications_none),
                        onPressed: () {
                          Get.snackbar(
                            'Notifikasi',
                            'Fitur notifikasi belum tersedia.',
                            backgroundColor: Colors.teal.shade200,
                            snackPosition: SnackPosition.TOP,
                          );
                        },
                        tooltip: 'Notifikasi',
                      ),
                    ]
                    : null),
      ),
      body: IndexedStack(
        // <--- Menggunakan IndexedStack untuk mempertahankan status
        index: _currentIndex,
        children: pages,
      ),
      floatingActionButton: SizedBox(
        width: 56,
        height: 56,
        child: FloatingActionButton(
          shape: const CircleBorder(),
          onPressed: () => setState(() => _currentIndex = 2), // Kembali ke Home
          backgroundColor: Colors.teal,
          elevation: 8,
          child: const Icon(Icons.home, size: 28, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: iconList,
        // Logika activeIndex: jika _currentIndex adalah 2 (home), tidak ada ikon aktif di bottom bar.
        // Jika _currentIndex < 2, gunakan index tersebut. Jika > 2, kurangi 1.
        activeIndex:
            _currentIndex == 2
                ? -1
                : (_currentIndex < 2 ? _currentIndex : _currentIndex - 1),
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.sharpEdge,
        leftCornerRadius: 0,
        rightCornerRadius: 0,
        activeColor: Colors.white,
        inactiveColor: Colors.teal.shade100,
        backgroundColor: Colors.teal,
        iconSize: 28,
        onTap: (index) {
          // Sesuaikan _currentIndex berdasarkan indeks dari bottom nav bar
          int actualIndex = index < 2 ? index : index + 1;
          setState(() {
            _currentIndex = actualIndex;
          });
        },
      ),
    );
  }
}
