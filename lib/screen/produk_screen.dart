// lib/screen/produk_screen.dart (Final)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../model/produk.dart';
import '../providers/produk_provider.dart';
import 'package:intl/intl.dart'; // Tambahkan ini untuk format harga

class ProdukScreen extends StatefulWidget {
  const ProdukScreen({super.key});

  @override
  State<ProdukScreen> createState() => _ProdukScreenState();
}

class _ProdukScreenState extends State<ProdukScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Produk> _filteredProdukList = [];

  // Controller untuk form tambah/edit produk
  final _kodeController = TextEditingController();
  final _namaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _hargaBeliController = TextEditingController();
  final _hargaJualController = TextEditingController();
  final _stokController = TextEditingController();
  final _stokMinController = TextEditingController();
  final _satuanDetailController = TextEditingController();

  String? _selectedKategori;
  String _selectedSatuanPokok = 'Pcs';

  // Untuk edit produk
  Produk? _produkToEdit;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterProduk);
    // Saat inisialisasi, ambil data produk dan filter
    Provider.of<ProdukProvider>(context, listen: false).fetchProduk().then((_) {
      _filterProduk();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Panggil filter setiap kali dependensi berubah (termasuk setelah fetchProduk)
    _filterProduk();
  }

  void _filterProduk() {
    final query = _searchController.text.toLowerCase();
    final produkList =
        Provider.of<ProdukProvider>(context, listen: false).produkList;

    setState(() {
      _filteredProdukList =
          query.isEmpty
              ? produkList
              : produkList.where((produk) {
                return produk.nama.toLowerCase().contains(query) ||
                    produk.kodeProduk.toLowerCase().contains(query);
              }).toList();
    });
  }

  void _tambahAtauUpdateProduk(BuildContext ctx) async {
    final produkProvider = Provider.of<ProdukProvider>(ctx, listen: false);

    final kode = _kodeController.text.trim();
    final nama = _namaController.text.trim();
    final deskripsi = _deskripsiController.text.trim();
    final kategori = _selectedKategori ?? '';
    final hargaBeli = double.tryParse(_hargaBeliController.text.trim()) ?? 0;
    final hargaJual = double.tryParse(_hargaJualController.text.trim()) ?? 0;
    final stok = int.tryParse(_stokController.text.trim()) ?? 0;
    final stokMin = int.tryParse(_stokMinController.text.trim()) ?? 0;
    final satuanDetail = _satuanDetailController.text.trim();
    final satuanFinal =
        '$_selectedSatuanPokok ${satuanDetail.isNotEmpty ? '($satuanDetail)' : ''}';

    if (kode.isEmpty ||
        nama.isEmpty ||
        hargaBeli <= 0 ||
        hargaJual <= 0 ||
        _selectedKategori == null ||
        _selectedKategori!.isEmpty) {
      Get.snackbar(
        'Error',
        'Pastikan semua data produk (Kode, Nama, Harga Beli, Harga Jual, Kategori) terisi dengan benar!',
        backgroundColor: Colors.orange.shade200,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      if (_produkToEdit == null) {
        final newProduk = Produk(
          id: '',
          kodeProduk: kode,
          nama: nama,
          deskripsi: deskripsi,
          kategori: kategori,
          hargaBeli: hargaBeli,
          hargaJual: hargaJual,
          stok: stok,
          stokMinimum: stokMin,
          satuan: satuanFinal,
        );
        await produkProvider.tambahProduk(newProduk);
        ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(content: Text('Produk berhasil ditambahkan!')),
        );
      } else {
        final updatedProduk = Produk(
          id: _produkToEdit!.id,
          kodeProduk: kode,
          nama: nama,
          deskripsi: deskripsi,
          kategori: kategori,
          hargaBeli: hargaBeli,
          hargaJual: hargaJual,
          stok: stok,
          stokMinimum: stokMin,
          satuan: satuanFinal,
        );
        await produkProvider.updateProduk(updatedProduk);
        ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(content: Text('Produk berhasil diperbarui!')),
        );
      }
      // Panggil fetchProduk() untuk memastikan data terbaru dimuat dari DB
      await produkProvider.fetchProduk();
      // Kemudian panggil _filterProduk untuk memperbarui tampilan setelah data baru diambil
      _filterProduk();
      Navigator.of(ctx).pop();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menyimpan produk: $e',
        backgroundColor: Colors.red.shade200,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _hapusProduk(String id) async {
    final produkProvider = Provider.of<ProdukProvider>(context, listen: false);
    try {
      await produkProvider.hapusProduk(id);
      // Panggil fetchProduk() untuk memastikan data terbaru dimuat dari DB
      await produkProvider.fetchProduk();
      _filterProduk(); // Perbarui tampilan setelah data baru diambil
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Produk berhasil dihapus!')));
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menghapus produk: $e',
        backgroundColor: Colors.red.shade200,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _showFormProduk({Produk? produk}) {
    _produkToEdit = produk;
    _kodeController.text = produk?.kodeProduk ?? '';
    _namaController.text = produk?.nama ?? '';
    _deskripsiController.text = produk?.deskripsi ?? '';
    _selectedKategori =
        produk?.kategori.isNotEmpty == true ? produk!.kategori : null;

    if (produk != null &&
        produk.satuan.contains('(') &&
        produk.satuan.contains(')')) {
      final parts = produk.satuan.split('(');
      _selectedSatuanPokok = parts[0].trim();
      _satuanDetailController.text = parts[1].replaceAll(')', '').trim();
    } else {
      _selectedSatuanPokok =
          produk?.satuan.isNotEmpty == true ? produk!.satuan : 'Pcs';
      _satuanDetailController.text = '';
    }

    _hargaBeliController.text = produk?.hargaBeli.toStringAsFixed(0) ?? '';
    _hargaJualController.text = produk?.hargaJual.toStringAsFixed(0) ?? '';
    _stokController.text = produk?.stok.toString() ?? '';
    _stokMinController.text = produk?.stokMinimum.toString() ?? '';

    showDialog(
      context: context,
      builder:
          (ctx) => StatefulBuilder(
            builder:
                (contextDialog, setStateDialog) => AlertDialog(
                  title: Text(produk == null ? 'Tambah Produk' : 'Edit Produk'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: _kodeController,
                          decoration: const InputDecoration(
                            labelText: 'Kode Produk',
                          ),
                          enabled: produk == null,
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
                            labelText: 'Kategori',
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
                              value: 'Rokok',
                              child: Text('Rokok'),
                            ),
                            DropdownMenuItem(
                              value: 'Kesehatan',
                              child: Text('Kesehatan'),
                            ),
                            DropdownMenuItem(
                              value: 'Aksesoris',
                              child: Text('Aksesoris'),
                            ),
                          ],
                          onChanged:
                              (value) => setStateDialog(
                                () => _selectedKategori = value,
                              ),
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
                          decoration: const InputDecoration(labelText: 'Stok'),
                        ),
                        TextField(
                          controller: _stokMinController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Stok Minimum',
                          ),
                        ),
                        DropdownButtonFormField<String>(
                          value: _selectedSatuanPokok,
                          decoration: const InputDecoration(
                            labelText: 'Satuan Pokok',
                          ),
                          items: const [
                            DropdownMenuItem(value: 'Pcs', child: Text('Pcs')),
                            DropdownMenuItem(value: 'Kg', child: Text('Kg')),
                            DropdownMenuItem(
                              value: 'Liter',
                              child: Text('Liter'),
                            ),
                          ],
                          onChanged:
                              (value) => setStateDialog(
                                () => _selectedSatuanPokok = value!,
                              ),
                        ),
                        TextField(
                          controller: _satuanDetailController,
                          decoration: const InputDecoration(
                            labelText: 'Detail Satuan (mis: botol, unit, grm)',
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(contextDialog).pop(),
                      child: const Text('Batal'),
                    ),
                    ElevatedButton(
                      onPressed: () => _tambahAtauUpdateProduk(contextDialog),
                      child: Text(produk == null ? 'Simpan' : 'Perbarui'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showUpdateStokDialog(Produk produk) {
    final TextEditingController stokUpdateController = TextEditingController(
      text: produk.stok.toString(),
    );
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text('Perbarui Stok ${produk.nama}'),
            content: TextField(
              controller: stokUpdateController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Stok Baru'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final newStok =
                      int.tryParse(stokUpdateController.text.trim()) ??
                      produk.stok;
                  if (newStok < 0) {
                    Get.snackbar(
                      'Error',
                      'Stok tidak bisa negatif.',
                      backgroundColor: Colors.red.shade200,
                    );
                    return;
                  }
                  try {
                    await Provider.of<ProdukProvider>(
                      context,
                      listen: false,
                    ).updateStok(produk.id, newStok);
                    // Panggil fetchProduk() untuk memastikan data terbaru dimuat dari DB
                    await Provider.of<ProdukProvider>(
                      context,
                      listen: false,
                    ).fetchProduk();
                    _filterProduk(); // Perbarui tampilan setelah data baru diambil
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Stok berhasil diperbarui!'),
                      ),
                    );
                  } catch (e) {
                    Get.snackbar(
                      'Error',
                      'Gagal memperbarui stok: $e',
                      backgroundColor: Colors.red.shade200,
                    );
                  }
                },
                child: const Text('Perbarui'),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterProduk);
    _searchController.dispose();
    _kodeController.dispose();
    _namaController.dispose();
    _deskripsiController.dispose();
    _hargaBeliController.dispose();
    _hargaJualController.dispose();
    _stokController.dispose();
    _stokMinController.dispose();
    _satuanDetailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Cari produk...',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showFormProduk(),
          ),
        ],
      ),
      body: Consumer<ProdukProvider>(
        builder: (context, produkProvider, child) {
          if (produkProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (_filteredProdukList.isEmpty &&
              _searchController.text.isEmpty) {
            return const Center(child: Text('Tidak ada produk tersedia.'));
          } else if (_filteredProdukList.isEmpty &&
              _searchController.text.isNotEmpty) {
            return const Center(
              child: Text('Tidak ada produk yang cocok dengan pencarian Anda.'),
            );
          }
          return ListView.builder(
            itemCount: _filteredProdukList.length,
            itemBuilder: (context, index) {
              final produk = _filteredProdukList[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        produk.nama,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('Kode: ${produk.kodeProduk}'),
                      Text('Kategori: ${produk.kategori}'),
                      Text(
                        'Harga Beli: Rp${NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(produk.hargaBeli)}',
                      ),
                      Text(
                        'Harga Jual: Rp${NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(produk.hargaJual)}',
                      ),
                      Text('Stok: ${produk.stok} ${produk.satuan}'),
                      Text('Stok Minimum: ${produk.stokMinimum}'),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showFormProduk(produk: produk),
                            ),
                            // Perbarui stok: Hapus 2 tombol ini, ganti dengan satu tombol stok yang jelas
                            IconButton(
                              icon: const Icon(
                                Icons.inventory,
                              ), // Icon yang lebih relevan untuk stok
                              onPressed: () => _showUpdateStokDialog(produk),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                Get.defaultDialog(
                                  title: 'Hapus Produk',
                                  middleText:
                                      'Anda yakin ingin menghapus produk "${produk.nama}"?',
                                  actions: [
                                    TextButton(
                                      onPressed: () => Get.back(),
                                      child: const Text('Batal'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        _hapusProduk(produk.id);
                                        Get.back();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      child: const Text(
                                        'Hapus',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
