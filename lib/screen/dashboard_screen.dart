import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:provider/provider.dart'; // Tambahkan import provider

import 'package:mobile_uas/screen/login_screen.dart';
import 'package:mobile_uas/screen/dashboard_home.dart';
import 'package:mobile_uas/screen/produk_screen.dart';
import 'package:mobile_uas/screen/transaksi_screen.dart';
import 'package:mobile_uas/screen/laporan_screen.dart';
import 'package:mobile_uas/screen/akun_screen.dart';
import 'package:mobile_uas/providers/auth_provider.dart'; // Tambahkan import AuthProvider

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 2; // Home di tengah (index ke-2)

  final iconList = <IconData>[
    Icons.inventory_2, // Produk
    Icons.receipt_long, // Transaksi
    Icons.bar_chart, // Laporan
    Icons.person, // Akun
  ];

  final List<String> titles = [
    'Produk',
    'Transaksi',
    'Toko Kelontong Makmur',
    'Laporan',
    'Akun',
  ];

  final List<Widget> pages = [
    ProdukScreen(), // 0
    const TransaksiScreen(), // 1
    const DashboardHome(), // 2
    const LaporanScreen(), // 3
    const AkunScreen(), // 4
  ];

  void _logout() async {
    // Ubah menjadi async
    try {
      // Panggil signOut dari AuthProvider
      await Provider.of<AuthProvider>(context, listen: false).signOut();
      Get.offAll(() => const LoginScreen());
      Get.snackbar(
        'Logout',
        'Anda berhasil logout',
        backgroundColor: Colors.green.shade300,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
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
        title: Text(titles[_currentIndex]),
        actions:
            _currentIndex == 4
                ? [
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: _logout,
                    tooltip: 'Logout',
                  ),
                ]
                : null,
      ),
      body: pages[_currentIndex],
      floatingActionButton: SizedBox(
        width: 56,
        height: 56,
        child: FloatingActionButton(
          shape: const CircleBorder(),
          onPressed: () => setState(() => _currentIndex = 2), // Home
          backgroundColor: Colors.green,
          elevation: 8,
          child: const Icon(Icons.home, size: 28),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: iconList,
        activeIndex: _currentIndex < 2 ? _currentIndex : _currentIndex - 1,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.sharpEdge,
        leftCornerRadius: 0,
        rightCornerRadius: 0,
        activeColor: Colors.white,
        inactiveColor: Colors.grey,
        backgroundColor: Colors.teal,
        iconSize: 28,
        onTap: (index) {
          int actualIndex = index < 2 ? index : index + 1;
          setState(() => _currentIndex = actualIndex);
        },
      ),
    );
  }
}
