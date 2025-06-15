// lib/screen/produk_screen.dart (Perbaikan Final Lengkap)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../model/produk.dart';
import '../providers/produk_provider.dart';
import 'package:intl/intl.dart';

class ProdukScreen extends StatefulWidget {
  const ProdukScreen({super.key});

  @override
  State<ProdukScreen> createState() => _ProdukScreenState();
}

class _ProdukScreenState extends State<ProdukScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Controller untuk form, tetap sama
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
  Produk? _produkToEdit;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  void _tambahAtauUpdateProduk(BuildContext dialogContext) async {
    final produkProvider = Provider.of<ProdukProvider>(
      dialogContext,
      listen: false,
    );

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
        '$_selectedSatuanPokok ${satuanDetail.isNotEmpty ? '($satuanDetail)' : ''}'
            .trim();

    if (kode.isEmpty ||
        nama.isEmpty ||
        hargaBeli <= 0 ||
        hargaJual <= 0 ||
        _selectedKategori == null ||
        _selectedKategori!.isEmpty) {
      Get.snackbar(
        'Error',
        'Pastikan semua data (Kode, Nama, Harga Beli, Harga Jual, Kategori) terisi.',
        backgroundColor: Colors.orange.shade200,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      if (_produkToEdit == null) {
        await produkProvider.tambahProduk(
          Produk(
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
          ),
        );
        Get.snackbar(
          'Sukses',
          'Produk berhasil ditambahkan!',
          backgroundColor: Colors.green.shade200,
        );
      } else {
        await produkProvider.updateProduk(
          Produk(
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
            isActive: _produkToEdit!.isActive,
          ),
        );
        Get.snackbar(
          'Sukses',
          'Produk berhasil diperbarui!',
          backgroundColor: Colors.green.shade200,
        );
      }
      Navigator.of(dialogContext).pop();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menyimpan produk: $e',
        backgroundColor: Colors.red.shade200,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _hapusProduk(String id, String namaProduk) {
    Get.defaultDialog(
      title: 'Hapus Produk',
      middleText:
          'Anda yakin ingin menghapus produk "$namaProduk"? Tindakan ini akan menonaktifkannya dari daftar.',
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
        ElevatedButton(
          onPressed: () async {
            Get.back();
            try {
              await Provider.of<ProdukProvider>(
                context,
                listen: false,
              ).hapusProduk(id);
              Get.snackbar(
                'Sukses',
                'Produk "$namaProduk" berhasil dinonaktifkan.',
                backgroundColor: Colors.green.shade200,
              );
            } catch (e) {
              Get.snackbar(
                'Error',
                'Gagal menghapus produk: $e',
                backgroundColor: Colors.red.shade200,
              );
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Hapus', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  void _showFormProduk({Produk? produk}) {
    _produkToEdit = produk;

    _kodeController.text = produk?.kodeProduk ?? '';
    _namaController.text = produk?.nama ?? '';
    _deskripsiController.text = produk?.deskripsi ?? '';
    _selectedKategori =
        produk?.kategori.isNotEmpty == true ? produk!.kategori : null;

    if (produk != null && produk.satuan.contains('(')) {
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
    _stokController.text = produk?.stok.toString() ?? '0';
    _stokMinController.text = produk?.stokMinimum.toString() ?? '0';

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
                          items:
                              const [
                                    'Sembako',
                                    'Minuman',
                                    'Makanan Ringan',
                                    'Alat Kebersihan',
                                    'Rokok',
                                    'Kesehatan',
                                    'Aksesoris',
                                  ]
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ),
                                  )
                                  .toList(),
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
                          decoration: const InputDecoration(
                            labelText: 'Stok Awal',
                          ),
                          enabled: produk == null,
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
                          items:
                              const [
                                    'Pcs',
                                    'Kg',
                                    'Liter',
                                    'Bungkus',
                                    'Sachet',
                                    'Dus',
                                    'Pak',
                                  ]
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ),
                                  )
                                  .toList(),
                          onChanged:
                              (value) => setStateDialog(
                                () => _selectedSatuanPokok = value!,
                              ),
                        ),
                        TextField(
                          controller: _satuanDetailController,
                          decoration: const InputDecoration(
                            labelText: 'Detail Satuan (opsional)',
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

  @override
  void dispose() {
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
      floatingActionButton: FloatingActionButton(
        // --- PERBAIKAN DI SINI ---
        heroTag: 'produkFab',
        onPressed: () => _showFormProduk(),
        tooltip: 'Tambah Produk',
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari berdasarkan nama atau kode...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Consumer<ProdukProvider>(
                builder: (context, produkProvider, child) {
                  final String query = _searchController.text.toLowerCase();
                  final List<Produk> filteredList =
                      produkProvider.produkList.where((produk) {
                        final namaMatch = produk.nama.toLowerCase().contains(
                          query,
                        );
                        final kodeMatch = produk.kodeProduk
                            .toLowerCase()
                            .contains(query);
                        return namaMatch || kodeMatch;
                      }).toList();

                  if (produkProvider.isLoading &&
                      produkProvider.produkList.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (produkProvider.produkList.isEmpty) {
                    return Center(
                      child: TextButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tidak ada produk. Refresh?'),
                        onPressed: () => produkProvider.forceFetchProduk(),
                      ),
                    );
                  }

                  if (filteredList.isEmpty) {
                    return const Center(
                      child: Text(
                        'Tidak ada produk yang cocok dengan pencarian.',
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => produkProvider.forceFetchProduk(),
                    child: ListView.builder(
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final produk = filteredList[index];
                        final stokHabis = produk.stok <= 0;
                        final stokMenipis =
                            produk.stok > 0 &&
                            produk.stok <= produk.stokMinimum;
                        return Card(
                          color:
                              stokHabis
                                  ? Colors.red[100]
                                  : (stokMenipis ? Colors.orange[100] : null),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
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
                                const SizedBox(height: 4),
                                Text(
                                  'Kode: ${produk.kodeProduk} | Kategori: ${produk.kategori}',
                                ),
                                const Divider(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Harga Jual: Rp${NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(produk.hargaJual)}',
                                      ),
                                    ),
                                    Text(
                                      'Stok: ${produk.stok} ${produk.satuan}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Wrap(
                                    spacing: -8,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.blue,
                                        ),
                                        onPressed:
                                            () =>
                                                _showFormProduk(produk: produk),
                                        tooltip: 'Edit Produk',
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed:
                                            () => _hapusProduk(
                                              produk.id,
                                              produk.nama,
                                            ),
                                        tooltip: 'Hapus Produk',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
