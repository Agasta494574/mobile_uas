import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../service/produk_service.dart';
import '../model/produk.dart';

// Model produk
class Produk {
  final String kodeProduk;
  final String nama;
  final String deskripsi;
  final String kategori;
  final double hargaBeli;
  final double hargaJual;
  final int stok;
  final int stokMin;
  final String satuan;

  Produk({
    required this.kodeProduk,
    required this.nama,
    required this.deskripsi,
    required this.kategori,
    required this.hargaBeli,
    required this.hargaJual,
    required this.stok,
    required this.stokMin,
    required this.satuan,
  });
}

class ProdukScreen extends StatefulWidget {
  const ProdukScreen({super.key});

  @override
  State<ProdukScreen> createState() => _ProdukScreenState();
}

class _ProdukScreenState extends State<ProdukScreen> {
  final List<Produk> _produkList = [];
  List<Produk> _filteredProdukList = [];

  final TextEditingController _searchController = TextEditingController();

  final _kodeController = TextEditingController();
  final _namaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _kategoriController = TextEditingController();
  final _hargaBeliController = TextEditingController();
  final _hargaJualController = TextEditingController();
  final _stokController = TextEditingController();
  final _stokMinController = TextEditingController();
  final _keteranganSatuanController = TextEditingController();

  String _selectedSatuan = 'Pcs';
  String? _selectedKategori;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterProduk);
    _filteredProdukList = List.from(_produkList);
  }

  void _filterProduk() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProdukList =
          _produkList.where((produk) {
            return produk.nama.toLowerCase().contains(query) ||
                produk.kodeProduk.toLowerCase().contains(query);
          }).toList();
    });
  }

  void _tambahProduk() {
    final kode = _kodeController.text.trim();
    final nama = _namaController.text.trim();
    final deskripsi = _deskripsiController.text.trim();
    final kategori = _kategoriController.text.trim();
    final hargaBeli = double.tryParse(_hargaBeliController.text.trim());
    final hargaJual = double.tryParse(_hargaJualController.text.trim());
    final stok = int.tryParse(_stokController.text.trim());
    final stokMin = int.tryParse(_stokMinController.text.trim());
    final satuanKeterangan = _keteranganSatuanController.text.trim();
    final satuan = '$_selectedSatuan ($satuanKeterangan)';

    if (kode.isEmpty ||
        nama.isEmpty ||
        hargaBeli == null ||
        hargaJual == null ||
        stok == null ||
        stokMin == null ||
        satuanKeterangan.isEmpty) {
      Get.snackbar(
        'Error',
        'Isi semua field yang diperlukan dengan benar.',
        backgroundColor: Colors.orange.shade200,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() {
      final produk = Produk(
        kodeProduk: kode,
        nama: nama,
        deskripsi: deskripsi,
        kategori: kategori,
        hargaBeli: hargaBeli,
        hargaJual: hargaJual,
        stok: stok,
        stokMin: stokMin,
        satuan: satuan,
      );
      _produkList.add(produk);
      _filterProduk();
    });

    _kodeController.clear();
    _namaController.clear();
    _deskripsiController.clear();
    _kategoriController.clear();
    _hargaBeliController.clear();
    _hargaJualController.clear();
    _stokController.clear();
    _stokMinController.clear();
    _keteranganSatuanController.clear();
    _selectedSatuan = 'Pcs';

    Navigator.of(context).pop();
  }

  void _showFormTambah() {
    showDialog(
      context: context,
      builder:
          (_) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Tambah Produk'),
                  content: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextField(
                          controller: _kodeController,
                          decoration: const InputDecoration(
                            labelText: 'Kode Produk',
                          ),
                        ),
                        TextField(
                          controller: _namaController,
                          decoration: const InputDecoration(
                            labelText: 'Nama Produk',
                          ),
                        ),
                        TextField(
                          controller: _deskripsiController,
                          decoration: const InputDecoration(
                            labelText: 'Deskripsi',
                          ),
                        ),
                        DropdownButtonFormField<String>(
                          value: _selectedKategori,
                          decoration: const InputDecoration(
                            labelText: 'Kategori Produk',
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Sembako',
                              child: Text('Sembako'),
                            ),
                            DropdownMenuItem(
                              value: 'Minuman',
                              child: Text('Minuman'),
                            ),
                            DropdownMenuItem(
                              value: 'Makanan Ringan',
                              child: Text('Makanan Ringan'),
                            ),
                            DropdownMenuItem(
                              value: 'Alat Kebersihan',
                              child: Text('Alat Kebersihan'),
                            ),
                            DropdownMenuItem(
                              value: 'Kesehatan',
                              child: Text('Kesehatan'),
                            ),
                            DropdownMenuItem(
                              value: 'Rokok',
                              child: Text('Rokok'),
                            ),
                            DropdownMenuItem(
                              value: 'Aksesoris',
                              child: Text('Aksesoris'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedKategori = value!;
                            });
                          },
                        ),
                        TextField(
                          controller: _hargaBeliController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Harga Beli',
                          ),
                        ),
                        TextField(
                          controller: _hargaJualController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Harga Jual',
                          ),
                        ),
                        TextField(
                          controller: _stokController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Stok Awal',
                          ),
                        ),
                        DropdownButtonFormField<String>(
                          value: _selectedSatuan,
                          decoration: const InputDecoration(
                            labelText: 'Satuan Produk',
                          ),
                          items: const [
                            DropdownMenuItem(value: 'Pcs', child: Text('Pcs')),
                            DropdownMenuItem(
                              value: 'Berat',
                              child: Text('Berat'),
                            ),
                            DropdownMenuItem(
                              value: 'Volume',
                              child: Text('Volume'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedSatuan = value!;
                            });
                          },
                        ),
                        TextField(
                          controller: _keteranganSatuanController,
                          decoration: InputDecoration(
                            labelText:
                                _selectedSatuan == 'Pcs'
                                    ? 'Contoh: buah, unit, botol'
                                    : _selectedSatuan == 'Berat'
                                    ? 'Contoh: kg, gram, ons'
                                    : 'Contoh: liter, ml',
                          ),
                        ),
                        TextField(
                          controller: _stokMinController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Stok Minimum',
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Batal'),
                    ),
                    ElevatedButton(
                      onPressed: _tambahProduk,
                      child: const Text('Simpan'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _hapusProduk(int index) {
    setState(() {
      final produk = _filteredProdukList[index];
      _produkList.remove(produk);
      _filterProduk();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari produk...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(icon: const Icon(Icons.add), onPressed: _showFormTambah),
          ],
        ),
      ),
      body:
          _filteredProdukList.isEmpty
              ? const Center(child: Text('Tidak ada produk yang cocok.'))
              : ListView.builder(
                itemCount: _filteredProdukList.length,
                itemBuilder: (context, index) {
                  final produk = _filteredProdukList[index];
                  return ListTile(
                    title: Text('${produk.nama} (${produk.kodeProduk})'),
                    subtitle: Text(
                      'Stok: ${produk.stok} ${produk.satuan} • Rp${produk.hargaJual.toStringAsFixed(0)}\nKategori: ${produk.kategori}',
                    ),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _hapusProduk(index),
                    ),
                  );
                },
              ),
    );
  }
}
