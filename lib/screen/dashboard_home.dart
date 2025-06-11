// lib/screen/dashboard_home.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_uas/service/stock_movment_service.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Untuk format mata uang

import 'package:mobile_uas/screen/laporan_screen.dart';
import 'package:mobile_uas/screen/audit_screen.dart';
import 'package:mobile_uas/screen/stock_out_screen.dart';
import 'package:mobile_uas/screen/stock_in_screen.dart';
import 'package:mobile_uas/service/transaksi_service.dart';

class DashboardHome extends StatefulWidget {
  const DashboardHome({super.key});

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  final TransactionService _transactionService = TransactionService();
  final StockMovementService _stockMovementService = StockMovementService();

  bool _showData = true; // State untuk mengontrol visibilitas data
  int _stockInToday = 0;
  int _stockOutToday = 0;
  double _omsetToday = 0.0;
  double _keuntunganToday = 0.0;
  bool _isLoadingData = false;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() {
      _isLoadingData = true;
    });
    try {
      _stockInToday = await _stockMovementService.getStockInToday();
      _stockOutToday = await _stockMovementService.getStockOutToday();
      _omsetToday = await _transactionService.getOmsetToday();
      _keuntunganToday = await _transactionService.getKeuntunganToday();
    } catch (e) {
      print("Error fetching dashboard data: $e");
      // Optionally show a snackbar or error message
    } finally {
      setState(() {
        _isLoadingData = false;
      });
    }
  }

  // Toggle visibilitas data
  void _toggleDataVisibility() {
    setState(() {
      _showData = !_showData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _fetchDashboardData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bagian "Digitalisasi Bisnis Anda Sekarang"
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.teal.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Digitalisasikan Bisnis Anda Sekarang',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Jalankan bisnis Anda dengan lebih mudah menggunakan fitur premium.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bagian "Data hari ini"
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Data hari ini',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              _showData
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey.shade600,
                            ),
                            onPressed: _toggleDataVisibility,
                          ),
                        ],
                      ),
                      const Divider(height: 20, thickness: 1),
                      _isLoadingData
                          ? const Center(child: CircularProgressIndicator())
                          : GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            childAspectRatio: 2.5,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            children: [
                              _buildDataGridItem(
                                'Stok Masuk',
                                _showData ? _stockInToday.toString() : '******',
                                Colors.green.shade700,
                              ),
                              _buildDataGridItem(
                                'Stok Keluar',
                                _showData
                                    ? _stockOutToday.toString()
                                    : '******',
                                Colors.red.shade700,
                              ),
                              _buildDataGridItem(
                                'Omset',
                                _showData
                                    ? 'Rp${NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(_omsetToday)}'
                                    : 'Rp******',
                                Colors.blueAccent.shade700,
                              ),
                              _buildDataGridItem(
                                'Untung',
                                _showData
                                    ? 'Rp${NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(_keuntunganToday)}'
                                    : 'Rp******',
                                Colors.purple.shade700,
                              ),
                            ],
                          ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Get.to(() => const LaporanScreen());
                          },
                          icon: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.blueAccent,
                          ),
                          label: const Text(
                            'Lihat Laporan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent.shade100,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: Colors.blueAccent.shade100,
                              ),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Bagian "Tips"
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: Colors.amber.shade700,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Tips: Tambahkan setidaknya 5 barang',
                    style: TextStyle(
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- Bagian Menu Baru: Audit, Stok Masuk, Stok Keluar ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: [
                  // Audit
                  _buildMenuItem(
                    context,
                    icon: Icons.assignment_turned_in_outlined,
                    title: 'Audit',
                    onTap: () {
                      Get.to(() => const AuditScreen());
                    },
                  ),
                  // Stok Masuk
                  _buildMenuItem(
                    context,
                    icon: Icons.file_download,
                    title: 'Stok Masuk',
                    onTap: () {
                      Get.to(() => const StockInScreen());
                    },
                  ),
                  // Stok Keluar
                  _buildMenuItem(
                    context,
                    icon: Icons.file_upload,
                    title: 'Stok Keluar',
                    onTap: () {
                      Get.to(() => const StockOutScreen());
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildDataGridItem(String title, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.orange.shade700),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
