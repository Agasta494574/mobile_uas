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

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 2; // Home di tengah (index ke-2)
  bool _isHomeTapped = false; // Variabel untuk mengontrol animasi tap pada Home

  final iconList = <IconData>[
    Icons.inventory_2, // Produk (index 0)
    Icons.receipt_long, // Transaksi (index 1)
    Icons.bar_chart, // Laporan (index 2)
    Icons.person, // Akun (index 3)
  ];

  final List<String> appBarTitles = [
    'Produk',
    'Transaksi',
    'Moodev', // Untuk halaman DashboardHome
    'Laporan',
    'Akun',
  ];

  final List<Widget> pages = [
    const ProdukScreen(), // 0
    const TransaksiScreen(), // 1
    const DashboardHome(), // 2 (Home screen)
    const LaporanScreen(), // 3
    const AkunScreen(), // 4
  ];

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
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitles[_currentIndex]),
        backgroundColor: Colors.teal, // Warna AppBar menjadi Teal
        foregroundColor: Colors.white, // Warna teks dan ikon AppBar putih
        elevation: 0,
        actions:
            _currentIndex == 4
                ? [
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: _logout,
                    tooltip: 'Logout',
                  ),
                ]
                : (_currentIndex == 2
                    ? [
                      IconButton(
                        icon: const Icon(Icons.notifications_none),
                        onPressed: () {
                          Get.snackbar(
                            'Notifikasi',
                            'Fitur notifikasi belum tersedia.',
                            backgroundColor:
                                Colors
                                    .teal
                                    .shade200, // Notifikasi background teal muda
                            snackPosition: SnackPosition.TOP,
                          );
                        },
                        tooltip: 'Notifikasi',
                      ),
                    ]
                    : null),
      ),
      body: pages[_currentIndex],
      floatingActionButton: SizedBox(
        width: 56,
        height: 56,
        child: FloatingActionButton(
          shape: const CircleBorder(),
          onPressed: () {
            setState(() {
              _currentIndex = 2; // Set index ke Home
              _isHomeTapped = true; // Aktifkan animasi tap
              // Nonaktifkan animasi tap setelah sedikit waktu
              Future.delayed(const Duration(milliseconds: 200), () {
                if (mounted) {
                  setState(() {
                    _isHomeTapped = false;
                  });
                }
              });
            });
          },
          backgroundColor: Colors.teal, // Warna FAB menjadi Teal
          elevation: 8,
          child: AnimatedScale(
            // Wrap dengan AnimatedScale
            duration: const Duration(milliseconds: 150), // Durasi animasi
            scale: _isHomeTapped ? 1.1 : 1.0, // Skala ikon saat ditekan
            child: Icon(
              Icons.home,
              size: 28,
              color:
                  _currentIndex == 2
                      ? Colors.white
                      : Colors
                          .teal
                          .shade100, // Warna ikon berubah berdasarkan _currentIndex
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: iconList,
        activeIndex:
            _currentIndex == 0
                ? 0 // Produk
                : _currentIndex == 1
                ? 1 // Transaksi
                : _currentIndex == 3
                ? 2 // Laporan (mapped to index 2 in iconList)
                : _currentIndex == 4
                ? 3 // Akun (mapped to index 3 in iconList)
                : -1, // Tidak ada ikon aktif di BottomNav ketika di halaman Home
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.sharpEdge,
        leftCornerRadius: 0,
        rightCornerRadius: 0,
        activeColor: Colors.white,
        inactiveColor: Colors.teal.shade100, // Warna ikon tidak aktif teal muda
        backgroundColor: Colors.teal, // Warna background BottomNav menjadi Teal
        iconSize: 28,
        onTap: (index) {
          int actualIndex = index < 2 ? index : index + 1;
          setState(() {
            _currentIndex = actualIndex;
            // Pastikan _isHomeTapped false ketika ikon lain ditekan
            _isHomeTapped = false;
          });
        },
      ),
    );
  }
}
