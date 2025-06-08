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
import 'package:mobile_uas/providers/produk_provider.dart'; // Import ProdukProvider
import 'package:mobile_uas/model/produk.dart'; // Import Produk model

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 2; // Home di tengah (index ke-2)

  List<Produk> _lowStockProduk = []; // Daftar baru untuk produk stok rendah

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

  @override
  void initState() {
    super.initState();
    // Mendengarkan perubahan di ProdukProvider untuk memeriksa stok rendah
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProdukProvider>(
        context,
        listen: false,
      ).addListener(_checkLowStock);
      _checkLowStock(); // Pengecekan awal
    });
  }

  @override
  void dispose() {
    Provider.of<ProdukProvider>(
      context,
      listen: false,
    ).removeListener(_checkLowStock);
    super.dispose();
  }

  void _checkLowStock() {
    final produkProvider = Provider.of<ProdukProvider>(context, listen: false);
    final currentLowStock =
        produkProvider.produkList
            .where(
              (produk) => produk.stok <= produk.stokMinimum,
            ) // Memfilter produk yang stoknya menipis
            .toList();

    // Hanya tampilkan snackbar jika ada item stok rendah baru atau jika daftar berubah
    if (currentLowStock.length != _lowStockProduk.length ||
        !_lowStockProduk.every(currentLowStock.contains)) {
      setState(() {
        _lowStockProduk = currentLowStock;
      });

      if (_lowStockProduk.isNotEmpty) {
        for (var produk in _lowStockProduk) {
          Get.snackbar(
            'Stok Menipis!',
            'Stok ${produk.nama} (${produk.kodeProduk}) kini ${produk.stok} ${produk.satuan}. Segera restock!',
            backgroundColor: Colors.orange.shade300,
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 5),
            icon: const Icon(Icons.warning_amber, color: Colors.white),
          );
        }
      }
    }
  }

  void _logout() async {
    try {
      await Provider.of<AuthProvider>(
        context,
        listen: false,
      ).signOut(); // Memanggil signOut dari AuthProvider
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
            _currentIndex ==
                    4 // Hanya tampilkan tombol logout di AkunScreen
                ? [
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: _logout,
                    tooltip: 'Logout',
                  ),
                ]
                : null,
      ),
      body: IndexedStack(
        // Gunakan IndexedStack untuk mempertahankan status halaman
        index: _currentIndex,
        children: pages,
      ),
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
