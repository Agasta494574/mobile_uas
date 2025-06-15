// lib/screen/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:mobile_uas/providers/stock_movment_provider.dart';
import 'package:mobile_uas/providers/transaksi_provider.dart';
import 'package:provider/provider.dart';

import 'package:mobile_uas/screen/login_screen.dart';
import 'package:mobile_uas/screen/dashboard_home.dart';
import 'package:mobile_uas/screen/produk_screen.dart';
import 'package:mobile_uas/screen/transaksi_screen.dart';
import 'package:mobile_uas/screen/laporan_screen.dart';
import 'package:mobile_uas/screen/akun_screen.dart';
import 'package:mobile_uas/providers/auth_provider.dart';
import 'package:mobile_uas/providers/produk_provider.dart';
import 'package:mobile_uas/model/user.dart' as AppUser;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 2;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchInitialData();
    });
  }

  void _fetchInitialData() {
    Provider.of<ProdukProvider>(context, listen: false).fetchProduk();
    Provider.of<TransaksiProvider>(context, listen: false).fetchTransactions();
    Provider.of<StockMovementProvider>(
      context,
      listen: false,
    ).fetchStockMovements();
  }

  final iconList = <IconData>[
    Icons.inventory_2,
    Icons.receipt_long,
    Icons.bar_chart,
    Icons.person,
  ];

  final List<Widget> pages = [
    const ProdukScreen(),
    const TransaksiScreen(),
    const DashboardHome(),
    const LaporanScreen(),
    const AkunScreen(),
  ];

  String _getAppBarTitle(int index, AppUser.User? currentUser) {
    switch (index) {
      case 0:
        return 'Produk';
      case 1:
        return 'Transaksi';
      case 2:
        return currentUser?.username ?? 'Toko Babe';
      case 3:
        return 'Laporan';
      case 4:
        return 'Akun';
      default:
        return 'Dashboard';
    }
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
        title: Text(_getAppBarTitle(_currentIndex, currentUser)),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
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
                            backgroundColor: Colors.teal.shade200,
                            snackPosition: SnackPosition.TOP,
                          );
                        },
                        tooltip: 'Notifikasi',
                      ),
                    ]
                    : null),
      ),
      body: IndexedStack(index: _currentIndex, children: pages),
      floatingActionButton: SizedBox(
        width: 56,
        height: 56,
        child: FloatingActionButton(
          // --- PERBAIKAN DI SINI ---
          heroTag: 'dashboardFab',
          shape: const CircleBorder(),
          onPressed: () => setState(() => _currentIndex = 2),
          backgroundColor: Colors.teal,
          elevation: 8,
          child: const Icon(Icons.home, size: 28, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: iconList,
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
          int actualIndex = index < 2 ? index : index + 1;
          setState(() {
            _currentIndex = actualIndex;
          });
        },
      ),
    );
  }
}
