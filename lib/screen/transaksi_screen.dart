// lib/screen/transaksi_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:mobile_uas/model/produk.dart';
import 'package:mobile_uas/model/transaksi.dart'; // Import model Transaksi
import 'package:mobile_uas/model/transaksi_detail.dart'; // Import model TransaksiDetail
import 'package:mobile_uas/providers/produk_provider.dart';
import 'package:mobile_uas/providers/transaksi_provider.dart'; // Import TransaksiProvider
import 'package:mobile_uas/providers/auth_provider.dart'; // <--- BARU: Import AuthProvider
import 'package:uuid/uuid.dart';

class CartItem {
  Produk produk;
  int jumlah;
  CartItem({required this.produk, required this.jumlah});
}

class TransaksiScreen extends StatefulWidget {
  const TransaksiScreen({super.key});

  @override
  State<TransaksiScreen> createState() => _TransaksiScreenState();
}

class _TransaksiScreenState extends State<TransaksiScreen> {
  final TextEditingController _cariController = TextEditingController();
  final TextEditingController _jumlahController = TextEditingController();
  final Uuid _uuid = const Uuid();

  Produk? _produkTerpilih;
  List<CartItem> _keranjang = [];

  double get _totalBayar {
    double total = 0;
    for (var item in _keranjang) {
      total += item.produk.hargaJual * item.jumlah;
    }
    return total;
  }

  void _tambahKeKeranjang() {
    if (_produkTerpilih == null) {
      Get.snackbar(
        'Error',
        'Pilih produk terlebih dahulu.',
        backgroundColor: Colors.orange.shade200,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    int jumlah = int.tryParse(_jumlahController.text) ?? 0;
    if (jumlah <= 0) {
      Get.snackbar(
        'Error',
        'Masukkan jumlah produk yang valid.',
        backgroundColor: Colors.orange.shade200,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (jumlah > _produkTerpilih!.stok) {
      Get.snackbar(
        'Error',
        'Stok tidak cukup. Stok tersedia: ${_produkTerpilih!.stok}',
        backgroundColor: Colors.orange.shade200,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() {
      final index = _keranjang.indexWhere(
        (item) => item.produk.id == _produkTerpilih!.id,
      );
      if (index >= 0) {
        int totalJumlah = _keranjang[index].jumlah + jumlah;
        if (totalJumlah > _produkTerpilih!.stok) {
          Get.snackbar(
            'Error',
            'Total jumlah melebihi stok yang tersedia.',
            backgroundColor: Colors.orange.shade200,
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }
        _keranjang[index].jumlah = totalJumlah;
      } else {
        _keranjang.add(CartItem(produk: _produkTerpilih!, jumlah: jumlah));
      }

      _produkTerpilih = null;
      _jumlahController.clear();
      _cariController.clear();
    });
  }

  void _hapusDariKeranjang(CartItem item) {
    setState(() {
      _keranjang.remove(item);
    });
  }

  void _simpanTransaksi() async {
    if (_keranjang.isEmpty) {
      Get.snackbar(
        'Error',
        'Keranjang masih kosong.',
        backgroundColor: Colors.orange.shade200,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final produkProvider = Provider.of<ProdukProvider>(context, listen: false);
    final transaksiProvider = Provider.of<TransaksiProvider>(
      context,
      listen: false,
    ); // Dapatkan TransaksiProvider
    final authProvider = Provider.of<AuthProvider>(
      context,
      listen: false,
    ); // <--- BARU: Dapatkan AuthProvider

    // <--- BARU: Pastikan user_id tersedia dari AuthProvider
    final currentUserId = authProvider.currentUser?.id;
    if (currentUserId == null) {
      Get.snackbar(
        'Error',
        'Anda harus login untuk melakukan transaksi.',
        backgroundColor: Colors.red.shade200,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    // <--- AKHIR BARU

    try {
      // 1. Buat ID transaksi unik
      final String transactionId = _uuid.v4();
      final DateTime now = DateTime.now();

      // 2. Buat objek Transaksi (Header)
      final newTransaksi = Transaksi(
        id: transactionId,
        tanggal: now,
        totalBayar: _totalBayar,
        userId: currentUserId, // <--- GUNAKAN USER_ID DARI AUTH PROVIDER
      );

      // 3. Buat list TransaksiDetail dari item di keranjang
      final List<TransaksiDetail> transaksiDetails = [];
      for (var item in _keranjang) {
        final detailId = _uuid.v4(); // ID unik untuk setiap detail
        transaksiDetails.add(
          TransaksiDetail(
            id: detailId,
            transaksiId: transactionId,
            produkId: item.produk.id,
            jumlah: item.jumlah,
            subtotal: item.produk.hargaJual * item.jumlah,
            productName: item.produk.nama, // Diisi untuk kenyamanan lokal
            productPricePerUnit:
                item.produk.hargaJual, // Diisi untuk kenyamanan lokal
          ),
        );
      }

      // 4. Panggil TransaksiProvider untuk menyimpan transaksi dan detailnya
      await transaksiProvider.addTransaction(newTransaksi, transaksiDetails);

      // 5. Kurangi stok produk sesuai jumlah pembelian
      for (var item in _keranjang) {
        await produkProvider.updateStok(
          item.produk.id,
          item.produk.stok - item.jumlah,
        );
      }

      // <--- BARU: Muat ulang data produk di ProdukProvider setelah transaksi
      await produkProvider.fetchProduk();

      setState(() {
        _keranjang.clear();
      });

      Get.snackbar(
        'Berhasil',
        'Transaksi berhasil disimpan dan stok diperbarui!',
        backgroundColor: Colors.green.shade200,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menyimpan transaksi atau memperbarui stok: ${e.toString()}',
        backgroundColor: Colors.red.shade200,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final produkProvider = Provider.of<ProdukProvider>(context);
    final List<Produk> _produkList = produkProvider.produkList;

    final hasilFilter =
        _produkList.where((produk) {
          return produk.nama.toLowerCase().contains(
            _cariController.text.toLowerCase(),
          );
        }).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            TextField(
              controller: _cariController,
              decoration: const InputDecoration(
                labelText: 'Cari produk...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            if (hasilFilter.isNotEmpty)
              DropdownButtonFormField<Produk>(
                value: _produkTerpilih,
                hint: const Text('Pilih Produk'),
                items:
                    hasilFilter
                        .map(
                          (produk) => DropdownMenuItem(
                            value: produk,
                            child: Text(
                              '${produk.nama} - Rp${produk.hargaJual.toStringAsFixed(0)} (Stok: ${produk.stok})',
                            ),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    _produkTerpilih = value;
                  });
                },
              ),
            const SizedBox(height: 12),
            TextField(
              controller: _jumlahController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Jumlah Beli',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _tambahKeKeranjang,
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Tambah ke Keranjang'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Keranjang Belanja:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            if (_keranjang.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text('Keranjang kosong'),
              ),
            ..._keranjang.map((item) {
              return ListTile(
                title: Text('${item.produk.nama}'),
                subtitle: Text('Jumlah: ${item.jumlah}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Subtotal: Rp${(item.produk.hargaJual * item.jumlah).toStringAsFixed(0)}',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _hapusDariKeranjang(item),
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 20),
            Text(
              'Total Bayar: Rp${_totalBayar.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _simpanTransaksi,
                icon: const Icon(Icons.save),
                label: const Text('Simpan Transaksi'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
