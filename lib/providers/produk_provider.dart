// lib/providers/produk_provider.dart
import 'package:flutter/material.dart';
import '../model/produk.dart';
import '../service/produk_service.dart';

class ProdukProvider extends ChangeNotifier {
  final ProdukService _produkService = ProdukService();

  List<Produk> _produkList = [];
  List<Produk> get produkList => _produkList;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  ProdukProvider() {
    fetchProduk();
  }

  Future<void> fetchProduk() async {
    _isLoading = true;
    notifyListeners();

    try {
      // ProdukService.getSemuaProduk sekarang hanya mengambil yang is_active = true
      _produkList = await _produkService.getSemuaProduk();
    } catch (e) {
      print('Error di ProdukProvider.fetchProduk: $e');
      _produkList = [];
      // TODO: Tampilkan pesan error ke UI jika diperlukan
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> tambahProduk(Produk produk) async {
    try {
      await _produkService.tambahProduk(produk);
      await fetchProduk(); // Refresh seluruh list setelah insert
    } catch (e) {
      print('Error di ProdukProvider.tambahProduk: $e');
      throw e;
    }
  }

  Future<void> updateStok(String id, int stokBaru) async {
    try {
      await _produkService.updateStok(id, stokBaru);
      // Perbarui list lokal
      int index = _produkList.indexWhere((p) => p.id == id);
      if (index >= 0) {
        final produkLama = _produkList[index];
        _produkList[index] = Produk(
          id: produkLama.id,
          kodeProduk: produkLama.kodeProduk,
          nama: produkLama.nama,
          deskripsi: produkLama.deskripsi,
          kategori: produkLama.kategori,
          hargaBeli: produkLama.hargaBeli,
          hargaJual: produkLama.hargaJual,
          stok: stokBaru,
          stokMinimum: produkLama.stokMinimum,
          satuan: produkLama.satuan,
          isActive: produkLama.isActive, // <--- Pastikan ini juga diperbarui
        );
        notifyListeners();
      }
    } catch (e) {
      print('Error di ProdukProvider.updateStok: $e');
      throw e;
    }
  }

  Future<void> updateProduk(Produk produk) async {
    try {
      await _produkService.updateProduk(produk);
      int index = _produkList.indexWhere((p) => p.id == produk.id);
      if (index >= 0) {
        _produkList[index] = produk;
        notifyListeners();
      }
    } catch (e) {
      print('Error di ProdukProvider.updateProduk: $e');
      throw e;
    }
  }

  // Ganti implementasi hapusProduk menjadi "deactivate"
  Future<void> hapusProduk(String id) async {
    // Nama metode tetap hapusProduk di provider untuk konsistensi di UI
    try {
      await _produkService.deactivateProduk(
        id,
      ); // <--- Panggil metode deactivateProduk di service
      await fetchProduk(); // Refresh list untuk menyembunyikan produk yang dinonaktifkan
    } catch (e) {
      print('Error di ProdukProvider.hapusProduk: $e');
      throw e;
    }
  }
}
