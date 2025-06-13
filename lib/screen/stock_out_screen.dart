// lib/screen/stock_out_screen.dart
import 'package:flutter/material.dart';
import 'package:mobile_uas/providers/stock_movment_provider.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart'; // Untuk generate UUID jika diperlukan

import 'package:mobile_uas/model/produk.dart';
import 'package:mobile_uas/providers/produk_provider.dart';
import 'package:mobile_uas/providers/auth_provider.dart'; // Untuk mendapatkan userId

class StockOutScreen extends StatefulWidget {
  const StockOutScreen({super.key});

  @override
  State<StockOutScreen> createState() => _StockOutScreenState();
}

class _StockOutScreenState extends State<StockOutScreen> {
  final _formKey = GlobalKey<FormState>();
  Produk? _selectedProduk;
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();

  @override
  void dispose() {
    _quantityController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _addStockOut() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedProduk == null) {
        Get.snackbar(
          'Error',
          'Pilih produk terlebih dahulu.',
          backgroundColor: Colors.red.shade200,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final int quantity = int.tryParse(_quantityController.text) ?? 0;
      final String reason = _reasonController.text.trim();

      if (quantity <= 0) {
        Get.snackbar(
          'Error',
          'Jumlah stok keluar harus lebih dari 0.',
          backgroundColor: Colors.red.shade200,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      if (reason.isEmpty) {
        Get.snackbar(
          'Error',
          'Alasan stok keluar tidak boleh kosong.',
          backgroundColor: Colors.red.shade200,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Validasi Stok Sebelum Pengurangan
      if (_selectedProduk!.stok < quantity) {
        Get.snackbar(
          'Stok Tidak Cukup',
          'Jumlah yang dikeluarkan (${quantity}) melebihi stok tersedia (${_selectedProduk!.stok}).',
          backgroundColor: Colors.orange.shade200,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final stockMovementProvider = Provider.of<StockMovementProvider>(
        context,
        listen: false,
      );
      final produkProvider = Provider.of<ProdukProvider>(
        context,
        listen: false,
      );
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final currentUserId = authProvider.currentUser?.id;
      if (currentUserId == null) {
        Get.snackbar(
          'Error',
          'Anda harus login untuk mencatat pergerakan stok.',
          backgroundColor: Colors.red.shade200,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      try {
        bool success = await stockMovementProvider.addStockOut(
          produk: _selectedProduk!,
          quantity: quantity,
          reason: reason,
          userId: currentUserId,
        );

        if (!mounted) return;

        if (success) {
          // Refresh data produk di ProdukProvider agar DashboardHome & ProdukScreen terupdate
          await produkProvider.fetchProduk();
          Get.snackbar(
            'Sukses',
            'Stok keluar berhasil dicatat!',
            backgroundColor: Colors.green.shade200,
            snackPosition: SnackPosition.BOTTOM,
          );
          Get.back(); // Kembali ke halaman sebelumnya
        } else {
          Get.snackbar(
            'Gagal',
            stockMovementProvider.errorMessage ?? 'Gagal mencatat stok keluar.',
            backgroundColor: Colors.red.shade200,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } catch (e) {
        if (!mounted) return;
        Get.snackbar(
          'Error',
          'Terjadi kesalahan: ${e.toString()}',
          backgroundColor: Colors.red.shade200,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final produkProvider = Provider.of<ProdukProvider>(context);
    final stockMovementProvider = Provider.of<StockMovementProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stok Keluar Baru'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<Produk>(
                value: _selectedProduk,
                hint: const Text('Pilih Produk'),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Produk',
                ),
                items:
                    produkProvider.produkList.map((produk) {
                      return DropdownMenuItem(
                        value: produk,
                        child: Text(
                          '${produk.nama} (Stok: ${produk.stok} ${produk.satuan})',
                        ),
                      );
                    }).toList(),
                onChanged: (Produk? newValue) {
                  setState(() {
                    _selectedProduk = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Produk tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Jumlah Stok Keluar',
                  hintText: 'Masukkan jumlah stok yang keluar',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah tidak boleh kosong';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Masukkan jumlah yang valid (angka positif)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Alasan Stok Keluar',
                  hintText: 'Misal: Rusak, Expired, Penggunaan Internal',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Alasan tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      stockMovementProvider.isLoading ? null : _addStockOut,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child:
                      stockMovementProvider.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'Catat Stok Keluar',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
