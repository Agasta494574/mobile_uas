import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Produk {
  final String nama;
  final double harga;
  int stok; // Tambah properti stok

  Produk({required this.nama, required this.harga, required this.stok});
}

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

  final List<Produk> _produkList = [
    Produk(nama: 'Beras', harga: 12000, stok: 20),
    Produk(nama: 'Gula', harga: 14000, stok: 15),
    Produk(nama: 'Minyak', harga: 17000, stok: 10),
    Produk(nama: 'Telur', harga: 22000, stok: 30),
  ];

  Produk? _produkTerpilih;
  List<CartItem> _keranjang = [];

  double get _totalBayar {
    double total = 0;
    for (var item in _keranjang) {
      total += item.produk.harga * item.jumlah;
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
        (item) => item.produk == _produkTerpilih,
      );
      if (index >= 0) {
        // Update jumlah, cek stok dulu
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

      // Reset input
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

  void _simpanTransaksi() {
    if (_keranjang.isEmpty) {
      Get.snackbar(
        'Error',
        'Keranjang masih kosong.',
        backgroundColor: Colors.orange.shade200,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Kurangi stok produk sesuai jumlah pembelian
    setState(() {
      for (var item in _keranjang) {
        item.produk.stok -= item.jumlah;
      }
      _keranjang.clear();
    });

    Get.snackbar(
      'Berhasil',
      'Transaksi berhasil disimpan!',
      backgroundColor: Colors.green.shade200,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
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
                              '${produk.nama} - Rp${produk.harga.toStringAsFixed(0)} (Stok: ${produk.stok})',
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
                      'Subtotal: Rp${(item.produk.harga * item.jumlah).toStringAsFixed(0)}',
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
